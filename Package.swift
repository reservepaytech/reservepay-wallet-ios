// swift-tools-version: 5.5
import PackageDescription

// binary URLs + checksums must match the tagged GitHub Release assets (zip names and bytes).
// Patched on each release by wallet-sdk CI — see .github/scripts/update_reservepay_wallet_ios_package_swift.py
let reservepayWalletSdkURL =
    "https://github.com/reservepaytech/reservepay-wallet-ios/releases/download/1.0.0/ReservepayWalletSDK.xcframework.zip"
let reservepayWalletSdkChecksum =
    "0000000000000000000000000000000000000000000000000000000000000000"

let ainuLivenessKitURL =
    "https://github.com/reservepaytech/reservepay-wallet-ios/releases/download/1.0.0/AinuLivenessKit.xcframework.zip"
let ainuLivenessKitChecksum =
    "0000000000000000000000000000000000000000000000000000000000000000"

let reservepayWalletSdkUiURL =
    "https://github.com/reservepaytech/reservepay-wallet-ios/releases/download/1.0.0/ReservepayWalletSDKUI.xcframework.zip"
let reservepayWalletSdkUiChecksum =
    "0000000000000000000000000000000000000000000000000000000000000000"

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
