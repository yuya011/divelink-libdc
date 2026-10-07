# libdc-swift の Swift 部分（LGPL-2.1）。接続・ダウンロード・解析
Pod::Spec.new do |s|
  s.name           = 'LibDCSwift'
  s.version        = '0.9.0'
  s.summary        = 'libdc-swift: Swift interface to libdivecomputer over BLE (LGPL-2.1)'
  s.license        = { :type => 'LGPL-2.1', :file => 'vendor/LICENSE-libdc-swift.txt' }
  s.author         = 'Deep Sea Labs'
  s.homepage       = 'https://github.com/deepsealabs/libdc-swift'
  s.platforms      = { :ios => '15.1' }
  s.source         = { git: '' }
  s.static_framework = true
  s.swift_version  = '5.9'

  s.dependency 'Clibdivecomputer'
  s.dependency 'LibDCBridge'
  s.frameworks = 'CoreBluetooth', 'Foundation', 'Combine', 'SwiftUI', 'UIKit'

  s.source_files = 'vendor/LibDCSwift/**/*.swift'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_SUPPRESS_WARNINGS' => 'YES'
  }
end
