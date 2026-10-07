# divelink-libdc — Third-party software notice

This module lets the DiveLink iOS app download dive logs from Bluetooth dive computers.
It bundles the following third-party libraries in `ios/vendor/`.

| Library | License | Source | Version used |
|---|---|---|---|
| libdivecomputer (Deep Sea Labs fork) | LGPL-2.1-or-later (`ios/vendor/libdivecomputer/COPYING`) | https://github.com/deepsealabs/libdivecomputer (upstream: https://www.libdivecomputer.org/) | see `ios/vendor/VERSIONS.txt` |
| libdc-swift | LGPL-2.1 (`ios/vendor/LICENSE-libdc-swift.txt`) | https://github.com/deepsealabs/libdc-swift | see `ios/vendor/VERSIONS.txt` |
| heatshrink (inside libdivecomputer) | ISC (`ios/vendor/libdivecomputer/src/heatshrink/LICENSE`) | https://github.com/atomicobject/heatshrink | as included in libdivecomputer |

The DiveLink-specific glue (`ios/DivelinkLibdcModule.swift`, the podspecs, and the JavaScript in
`src/services/diveComputer/`) is DiveLink's own code that uses these libraries through their public interfaces.

## Modifications made by DiveLink

All changes to the bundled sources are listed here (LGPL-2.1 §2(a)).

1. **`ios/vendor/LibDCSwift/BLEManager.swift`** (2026-10-07): `CoreBluetoothManager.init` no longer passes
   `CBCentralManagerOptionRestoreIdentifierKey`. State restoration requires the `bluetooth-central`
   background mode, and iOS terminates apps that request restoration without it. DiveLink only talks to
   dive computers while its import screen is open and does not declare that background mode.
2. **`ios/vendor/LibDCBridge/include/module.modulemap`** was moved to `ios/vendor/LibDCBridge/LibDCBridge.modulemap`
   (contents unchanged) so that CocoaPods does not load the same module map twice.
3. Files not needed to build the library on iOS were left out: libdivecomputer `examples/`, `doc/`, `m4/`,
   `contrib/`, the autotools files (`Makefile.am`, `version.h.in`), Windows-only files (`serial_win32.c`,
   `libdivecomputer.rc`, `libdivecomputer.symbols`), and the libdc-swift test app and tests.

## How DiveLink meets the LGPL-2.1 conditions

- The DiveLink iOS app shows these libraries, their licenses, and how to obtain the source
  (Settings > Support > データ提供元・ライセンス > オープンソースソフトウェア).
- The complete source of the libraries as used (this directory, including the modifications above) is
  published at https://github.com/yuya011/divelink-libdc, and is also provided on request through
  https://lp.divelink.jp/contact for at least three years after the last distribution of the app, for no more
  than the cost of providing it (LGPL-2.1 §6(c)).
- Because iOS apps link these libraries statically, DiveLink will also provide, on the same terms, the
  object files of the app needed to relink it with a modified version of the libraries (LGPL-2.1 §6(a)/(c)).
- The App Store standard EULA states that open-source components are governed by their own license terms,
  so it does not restrict the modification and reverse engineering that LGPL-2.1 §6 permits for these libraries.
