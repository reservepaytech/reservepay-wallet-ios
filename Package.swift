// swift-tools-version: 5.5
import PackageDescription

// binary URLs + checksums must match the tagged GitHub Release assets (zip names and bytes).
// Patched on each release by wallet-sdk CI — see .github/scripts/update_reservepay_wallet_ios_package_swift.py
let reservepayWalletSdkURL =
    "https://github.com/reservepaytech/reservepay-wallet-ios/releases/download/1.0.0/ReservepayWalletSDK.xcframework.zip"
let reservepayWalletSdkChecksum =
    "99c671029050017b342742c3a56c7d1fc78a381c43ca9861f00cfdb272f1730a"

let ainuLivenessKitURL =
    "https://github.com/reservepaytech/reservepay-wallet-ios/releases/download/1.0.0/AinuLivenessKit.xcframework.zip"
let ainuLivenessKitChecksum =
    "5dde65bf5488b185b2ca260e6301642c1463cdda6f9c3d5ff87c164b8dd73038"

let reservepayWalletSdkUiURL =
    "https://github.com/reservepaytech/reservepay-wallet-ios/releases/download/1.0.0/ReservepayWalletSDKUI.xcframework.zip"
let reservepayWalletSdkUiChecksum =
    "62d662948f706950b24afc9e610dc847b541dbe3bdee97bf6d37c49b241c4752"

let package = Package(
    name: "ReservepayWalletSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ReservepayWalletSDK", targets: ["ReservepayWalletSDK"]),
        .library(name: "AinuLivenessKit", targets: ["AinuLivenessKit"]),
        .library(name: "ReservepayWalletSDKUI", targets: ["ReservepayWalletSDKUI"]),
    ],
    targets: [
        .binaryTarget(
            name: "ReservepayWalletSDK",
            url: reservepayWalletSdkURL,
            checksum: reservepayWalletSdkChecksum,
        ),
        .binaryTarget(
            name: "AinuLivenessKit",
            url: ainuLivenessKitURL,
            checksum: ainuLivenessKitChecksum,
        ),
        .binaryTarget(
            name: "ReservepayWalletSDKUI",
            url: reservepayWalletSdkUiURL,
            checksum: reservepayWalletSdkUiChecksum,
        ),
    ],
)
