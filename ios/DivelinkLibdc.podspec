# DiveLink から libdc-swift を呼ぶための窓口（Expo モジュール）
Pod::Spec.new do |s|
  s.name           = 'DivelinkLibdc'
  s.version        = '1.0.0'
  s.summary        = 'libdivecomputer 経由でダイブコンピューターのログを読む'
  s.description    = 'libdc-swift（LGPL-2.1）を使い、BLE のダイブコンピューターからログを読み込む'
  s.author         = 'DiveLink'
  s.homepage       = 'https://divelink.jp'
  s.platforms      = { :ios => '15.1' }
  s.source         = { git: '' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'
  s.dependency 'LibDCSwift'
  s.dependency 'LibDCBridge'
  s.dependency 'Clibdivecomputer'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
  }

  s.source_files = 'DivelinkLibdcModule.swift'
end
