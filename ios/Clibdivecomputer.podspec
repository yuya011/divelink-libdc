# libdivecomputer（LGPL-2.1）。取り込んだ版は vendor/VERSIONS.txt、改変の記録は ../NOTICE.md
Pod::Spec.new do |s|
  s.name           = 'Clibdivecomputer'
  s.version        = '0.9.0'
  s.summary        = 'libdivecomputer: dive computer communication library (LGPL-2.1)'
  s.license        = { :type => 'LGPL-2.1', :file => 'vendor/libdivecomputer/COPYING' }
  s.author         = 'Jef Driesen and contributors'
  s.homepage       = 'https://www.libdivecomputer.org'
  s.platforms      = { :ios => '15.1' }
  s.source         = { git: '' }
  s.static_framework = true

  s.source_files         = 'vendor/libdivecomputer/src/**/*.{c,h}', 'vendor/libdivecomputer/include/libdivecomputer/*.h'
  s.public_header_files  = 'vendor/libdivecomputer/include/libdivecomputer/*.h'
  s.header_mappings_dir  = 'vendor/libdivecomputer/include'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/vendor/libdivecomputer/include" "${PODS_TARGET_SRCROOT}/vendor/libdivecomputer/include/libdivecomputer" "${PODS_TARGET_SRCROOT}/vendor/libdivecomputer/src"',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HAVE_PTHREAD_H=1 ENABLE_LOGGING=1',
    'GCC_WARN_INHIBIT_ALL_WARNINGS' => 'YES'
  }
end
