import ExpoModulesCore
import CoreBluetooth
import LibDCSwift

/// DiveLink から libdc-swift（libdivecomputer）を呼ぶ窓口。
///
/// 流れ: startScan → getDiscovered（見つかった機器を利用者が選ぶ）→ stopScan → open（名前から機種を判定して接続）→ download（全件）→ close。
/// libdc-swift の CoreBluetoothManager は共有の1つだけを使う。CoreBluetooth はメインスレッドで扱い、
/// 時間のかかる接続とダウンロードは libdc-swift が自前のキューで行う。
///
/// ダイコンへの書き込み（時計合わせ）はしない（syncClock: false）。
/// 取り込み済みかの判断は DiveLink 側で行うので、libdc-swift の「前回以降だけ」は使わない（useFingerprint: false）。
public class DivelinkLibdcModule: Module {
    private var viewModel: DiveDataViewModel?

    public func definition() -> ModuleDefinition {
        Name("DivelinkLibdc")
        Events("onProgress")

        Function("isAvailable") { () -> Bool in
            true
        }

        // 探索を始める。Bluetooth の準備ができるまで最大5秒待ち、使えなければ理由を返す。
        // 船の上などで同じ機種が複数見つかることがあるので、つなぐ機器は利用者に選んでもらう（getDiscovered）
        AsyncFunction("startScan") { (promise: Promise) in
            DispatchQueue.main.async {
                let manager = CoreBluetoothManager.sharedManager
                let deadline = Date().addingTimeInterval(5)

                func poll() {
                    switch manager.centralManager.state {
                    case .unauthorized:
                        promise.reject("ERR_UNAUTHORIZED", "Bluetooth の利用が許可されていません。設定アプリの DiveLink で Bluetooth を許可してください。")
                    case .poweredOff:
                        promise.reject("ERR_POWERED_OFF", "スマートフォンの Bluetooth が OFF になっています。")
                    case .unsupported:
                        promise.reject("ERR_UNSUPPORTED", "この端末は Bluetooth Low Energy に対応していません。")
                    case .poweredOn:
                        manager.clearDiscoveredPeripherals()
                        // 対応機種のサービスを広告している機器だけを探す
                        manager.startScanning(omitUnsupportedPeripherals: true)
                        promise.resolve(nil)
                    default:
                        if Date() > deadline {
                            promise.reject("ERR_UNSUPPORTED", "Bluetooth の準備ができませんでした。")
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: poll)
                        }
                    }
                }
                poll()
            }
        }

        // ここまでに見つかった機器（名前の無いものは除く）
        AsyncFunction("getDiscovered") { (promise: Promise) in
            DispatchQueue.main.async {
                let found = CoreBluetoothManager.sharedManager.discoveredPeripherals
                    .filter { $0.name != nil }
                    .map { ["id": $0.identifier.uuidString, "name": $0.name ?? ""] }
                promise.resolve(found)
            }
        }

        AsyncFunction("stopScan") { (promise: Promise) in
            DispatchQueue.main.async {
                CoreBluetoothManager.sharedManager.stopScanning()
                promise.resolve(nil)
            }
        }

        AsyncFunction("open") { (id: String, name: String, promise: Promise) in
            // openBLEDevice は接続と機種ごとの手順が終わるまで戻らない。メインスレッドでは呼ばない
            DispatchQueue.global(qos: .userInitiated).async {
                if DeviceConfiguration.openBLEDevice(name: name, deviceAddress: id) {
                    promise.resolve(true)
                } else {
                    promise.reject("ERR_CONNECT", "\(name) に接続できませんでした。")
                }
            }
        }

        AsyncFunction("download") { (promise: Promise) in
            DispatchQueue.main.async {
                let manager = CoreBluetoothManager.sharedManager
                guard let devicePtr = manager.openedDeviceDataPtr, let device = manager.connectedDevice else {
                    promise.reject("ERR_CONNECT", "ダイブコンピューターに接続されていません。")
                    return
                }
                let vm = DiveDataViewModel()
                self.viewModel = vm
                DiveLogRetriever.retrieveDiveLogs(
                    from: devicePtr,
                    device: device,
                    viewModel: vm,
                    bluetoothManager: manager,
                    syncClock: false,
                    useFingerprint: false,
                    onProgress: { [weak self] current, total in
                        self?.sendEvent("onProgress", ["current": current, "total": total])
                    }
                ) { success in
                    DispatchQueue.main.async {
                        if success {
                            promise.resolve(vm.dives.map(Self.encode))
                        } else {
                            promise.reject("ERR_DOWNLOAD", vm.status.isEmpty ? "ログを読み込めませんでした。" : vm.status)
                        }
                    }
                }
            }
        }

        AsyncFunction("close") { (promise: Promise) in
            DispatchQueue.main.async {
                let manager = CoreBluetoothManager.sharedManager
                manager.stopScanning()
                manager.close(clearDevicePtr: true)
                self.viewModel = nil
                promise.resolve(nil)
            }
        }
    }

    private static let startFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    /// JS に渡す形。記録は [経過秒, 水深m, 水温℃ または null]。水温が欠けた記録は直前の値で埋める
    private static func encode(_ dive: DiveData) -> [String: Any] {
        var lastTemp: Double? = nil
        var samples: [[Any]] = []
        var events: [[String: Any]] = []
        for point in dive.profile {
            if let t = point.temperature { lastTemp = t }
            samples.append([point.time, point.depth, lastTemp.map { $0 as Any } ?? NSNull()])
            for event in point.events {
                events.append(["tSec": point.time, "kind": kind(of: event)])
            }
        }
        var result: [String: Any] = [
            "start": startFormatter.string(from: dive.datetime),
            "diveTimeSec": dive.divetime,
            "maxDepthM": dive.maxDepth,
            "avgDepthM": dive.avgDepth,
            "samples": samples,
            "events": events,
        ]
        if let minTemp = dive.minTemperature ?? (dive.temperature != 0 ? dive.temperature : nil) {
            result["minTempC"] = minTemp
        }
        return result
    }

    private static func kind(of event: DiveEvent) -> String {
        switch event {
        case .ascent: return "ascent"
        case .violation: return "violation"
        case .decoStop: return "decoStop"
        case .ceiling: return "ceiling"
        case .po2: return "po2"
        default: return "other"
        }
    }
}
