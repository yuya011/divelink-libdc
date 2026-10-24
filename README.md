# divelink-libdc

DiveLink（ダイビングのログブックアプリ）の iOS 版が、Bluetooth のダイブコンピューターからログを読み込むために使っている部分のソースコードです。
[libdivecomputer](https://www.libdivecomputer.org/) と [libdc-swift](https://github.com/deepsealabs/libdc-swift) を含みます。
どちらも GNU Lesser General Public License 2.1（LGPL）で提供されているため、DiveLink が使っているものを、変更箇所も含めてここで公開しています。

This repository contains the source code that the DiveLink iOS app (a scuba diving logbook) uses to download
dive logs from Bluetooth dive computers. It bundles libdivecomputer and libdc-swift, which are licensed under the
GNU Lesser General Public License 2.1 (LGPL). We publish them here as used by DiveLink, including our modifications.

## 中身 / Contents

| パス / Path | 内容 / What it is | ライセンス / License |
|---|---|---|
| `ios/vendor/libdivecomputer/` | libdivecomputer（Deep Sea Labs 版） | LGPL-2.1 or later |
| `ios/vendor/LibDCBridge/`, `ios/vendor/LibDCSwift/` | libdc-swift | LGPL-2.1 |
| `ios/vendor/libdivecomputer/src/heatshrink/` | heatshrink | ISC |
| `ios/*.podspec` | CocoaPods 用の部品定義 / CocoaPods specs | LGPL-2.1 |
| `ios/DivelinkLibdcModule.swift` | DiveLink から呼ぶための Expo モジュール / Expo module used by DiveLink | LGPL-2.1 |

取り込んだ版は `ios/vendor/VERSIONS.txt`、DiveLink による変更は [`NOTICE.md`](NOTICE.md) にあります。
The exact upstream revisions are listed in `ios/vendor/VERSIONS.txt`. All changes made by DiveLink are listed in [`NOTICE.md`](NOTICE.md).

## 使い方 / Building

Expo（React Native）のローカルモジュールとして、アプリの `modules/divelink-libdc/` に置いて使います。
Expo の自動リンクが `ios/` の4つの podspec を CocoaPods に登録します（iOS 15.1 以上）。

Place this directory at `modules/divelink-libdc/` in an Expo app. Expo autolinking registers the four podspecs in
`ios/` with CocoaPods (iOS 15.1+).

## 再リンクのための資料 / Relinking

DiveLink の iOS アプリはこれらのライブラリを静的に組み込んでいます。
改変したライブラリと DiveLink を再リンクするために必要な資料（アプリのオブジェクトファイル、リンクの手順など）は、
アプリの版ごとに [Releases](https://github.com/yuya011/divelink-libdc/releases) で公開しています（iOS 1.0.4 から）。
それ以前の版や、Releases に無いものは、[お問い合わせ](https://lp.divelink.jp/contact)からご依頼ください。
アプリを最後に配布した日から少なくとも3年間、送付に要する実費のみでお渡しします。

The DiveLink iOS app links these libraries statically. The materials needed to relink DiveLink with a modified version
of the libraries (the app's object files, the link command, and so on) are published for each app version in
[Releases](https://github.com/yuya011/divelink-libdc/releases), starting with iOS 1.0.4. For earlier versions or anything
not in Releases, contact us via https://lp.divelink.jp/contact. We provide them for at least three years after the last
distribution of the app, for no more than the cost of providing them.

## ライセンス / License

GNU Lesser General Public License 2.1（[`LICENSE`](LICENSE)）。heatshrink は ISC ライセンスです。
