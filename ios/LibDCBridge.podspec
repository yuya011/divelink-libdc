# libdc-swift の C/Objective-C 部分（LGPL-2.1）。libdivecomputer と CoreBluetooth の橋渡し
Pod::Spec.new do |s|
  s.name           = 'LibDCBridge'
  s.version        = '0.9.0'
  s.summary        = 'libdc-swift bridge between libdivecomputer and CoreBluetooth (LGPL-2.1)'
  s.license        = { :type => 'LGPL-2.1', :file => 'vendor/LICENSE-libdc-swift.txt' }
  s.author         = 'Deep Sea Labs'
  s.homepage       = 'https://github.com/deepsealabs/libdc-swift'
  s.platforms      = { :ios => '15.1' }
  s.source         = { git: '' }
  s.static_framework = true

  s.dependency 'Clibdivecomputer'
  s.frameworks = 'CoreBluetooth', 'Foundation'

  s.source_files        = 'vendor/LibDCBridge/src/*.{c,m}', 'vendor/LibDCBridge/include/*.h'
  s.public_header_files = 'vendor/LibDCBridge/include/*.h'
  s.module_map          = 'vendor/LibDCBridge/LibDCBridge.modulemap'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/vendor/LibDCBridge/include" "${PODS_TARGET_SRCROOT}/vendor/libdivecomputer/include" "${PODS_TARGET_SRCROOT}/vendor/libdivecomputer/src"',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) OBJC_OLD_DISPATCH_PROTOTYPES=1',
    'GCC_WARN_INHIBIT_ALL_WARNINGS' => 'YES'
  }
end
