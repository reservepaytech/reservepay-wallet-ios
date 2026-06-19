# Reservepay Wallet SDK — iOS

Swift Package Manager distribution for iOS: three binary XCFrameworks (**ReservepayWalletSDK**, *
*ReservepayWalletSDKUI**, **AinuLivenessKit**), downloaded from **GitHub Releases** when SPM
resolves the package.

## Requirements

- **iOS** 13.0 or later
- **Swift** 5.5 or later (matches `swift-tools-version` in `Package.swift`)
- A **published [GitHub Release](https://github.com/reservepaytech/reservepay-wallet-ios/releases)**
  whose tag and zip assets match **`Package.swift`** in this repo:
    - `ReservepayWalletSDK.xcframework.zip`
    - `AinuLivenessKit.xcframework.zip`
    - `ReservepayWalletSDKUI.xcframework.zip`

  Otherwise Xcode cannot download or verify the binaries.

## Add the package (Xcode)

1. **File → Add Package Dependencies…**
2. Repository URL:

   `https://github.com/reservepaytech/reservepay-wallet-ios.git`

3. Pick a rule: **Up to Next Major** (recommended once release tags exist), **Branch** (e.g.
   `main`), or **Exact Version** / **Commit**.
4. Add the package, then under **Add to Target** link **all three** products:
    - **ReservepayWalletSDK**
    - **ReservepayWalletSDKUI** (built-in auth / liveness UI)
    - **AinuLivenessKit** (face liveness)

```swift
import ReservepayWalletSDK
```

## Info.plist (required)

The host app **must** include **`CADisableMinimumFrameDurationOnPhone`** in **Info.plist** (Boolean
**`YES`**). The SDK expects this; omitting it can cause incorrect frame timing on device.

```xml

<key>CADisableMinimumFrameDurationOnPhone</key><true />
```

In Xcode: app target → **Info** → add **`CADisableMinimumFrameDurationOnPhone`**, type **Boolean**,
value **YES**.

For liveness, also add:

```xml

<key>NSCameraUsageDescription</key><string>Camera is used for face verification (liveness).</string>
```

## AinuLivenessKit license (required for liveness)

Wallet auth uses **AinuLivenessKit**. Follow AINU’s iOS integration guides:

- [Step 2 — Add
  `License.lic` to your project](https://ainu.tech/web/v1/developer/documentation/liveness-detection-sdk-for-ios/building-your-integration/get-started/step-2-ensuring-the-license-file-is-in-your-project-directory)
- [Step 3 — Add the Run Script in Xcode](https://ainu.tech/web/v1/developer/documentation/liveness-detection-sdk-for-ios/building-your-integration/get-started/step-3-adding-the-run-script-in-xcode)

**Wallet SDK layout** (same pattern as the wallet-sdk `iosApp` sample):

```text
YourApp/
  YourApp.xcodeproj
  AinuLivenessLicense/
    License.lic          ← from AINU / Reservepay; do not commit to public repos
```

**Run Script** (last build phase; replace key and env with your values):

```sh
"${SRCROOT}/AinuLivenessLicense/License.lic" \
  -key "YOUR_AINU_LICENSE_KEY" \
  -env "UAT" \
  -frameworks "AinuLivenessKit"
```

Use **`UAT`** for staging/dev and the production env value from AINU for release builds. You can
store the key in **Build Settings → User-Defined** (e.g. `AINU_LICENSE_KEY`, `AINU_LICENSE_ENV`) and
reference those variables in the script instead of literals.

Link **AinuLivenessKit** from this Swift package. If the script fails under sandboxing, set **Enable
User Script Sandboxing** to **No** on the app target.

## SDK setup

Call **`doInit`** once at app launch, before any other SDK APIs (for example in your `App` type’s
`init`).

```swift
import ReservepayWalletSDK

@main
struct MyApp: App {
    init() {
        ReservepayWalletSDK.companion.getInstance().doInit(
            isDebug: true,
            environment: Environment.production  // .development for staging
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Built-in UI:** **`startAuthentication`** and **`verifyLiveness`** need a **`UIViewController`** to
present SDK screens.

---

## Usage

Two styles:

- **Built-in auth UI** — the SDK presents login, liveness, and set-PIN flows (`startAuthentication`,
  `verifyLiveness`).
- **Programmatic APIs** — your app owns the UX and calls wallet, payment, and transfer APIs via
  callbacks.

### Built-in auth UI (`startAuthentication`)

The **`userSessionId`** comes from your backend (`start-user-session`).

- **New user:** liveness → set PIN
- **Existing user (same device):** PIN login
- **Existing user (new device):** liveness → continue

```swift
import ReservepayWalletSDK

ReservepayWalletSDK.companion.getInstance().startAuthentication(
    viewController: viewController,
    userSessionId: "USER_SESSION_ID",
    onSuccess: { /* authenticated or PIN set */ },
    onDismiss: { /* user closed the flow */ }
)
```

### Standalone liveness (`verifyLiveness`)

Requires an authenticated session.

```swift
ReservepayWalletSDK.companion.getInstance().verifyLiveness(
    viewController: viewController,
    onSuccess: { faceScanId in },
    onDismiss: {},
    onError: { _ in }
)
```

### Session APIs

```swift
let authenticated = ReservepayWalletSDK.companion.getInstance().isAuthenticated()

ReservepayWalletSDK.companion.getInstance().verifySession(
    callback: ReservepayBoolCallback(
        onSuccess: { isValid in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)

ReservepayWalletSDK.companion.getInstance().revokeAllSessions(
    callback: ReservepayBoolCallback(
        onSuccess: { _ in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)
```

### Programmatic APIs — wallets

```swift
ReservepayWalletSDK.companion.getInstance().getWallets(
    callback: ReservepayWalletsCallback(
        onSuccess: { wallets in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)

ReservepayWalletSDK.companion.getInstance().findWallet(
    walletId: "WALLET_ID",
    callback: ReservepayWalletCallback<Wallet>(
        onSuccess: { wallet in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)
```

### Programmatic APIs — payments

**Payment types:** `proxy` (PromptPay), `bill`, `account`. Funds are debited only after your backend
confirms the payment.

```swift
ReservepayWalletSDK.companion.getInstance().initiatePayment(
    walletId: "WALLET_ID",
    amount: "1.00",
    currency: "THB",
    type: "proxy",
    proxy: "1234567890123",
    accountNumber: nil,
    bankCode: nil,
    billerId: nil,
    ref1: nil,
    ref2: nil,
    ref3: nil,
    idempotencyKey: UUID().uuidString.lowercased(),
    callback: ReservepayWalletCallback<NSString>(
        onSuccess: { paymentId in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)

ReservepayWalletSDK.companion.getInstance().findPayment(
    paymentId: "PAYMENT_ID",
    callback: ReservepayWalletCallback<Payment>(
        onSuccess: { payment in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)
```

### Programmatic APIs — transfers

```swift
ReservepayWalletSDK.companion.getInstance().initiateTransfer(
    senderWalletId: "SENDER_WALLET_ID",
    receiverWalletId: "RECEIVER_WALLET_ID",
    amount: "10.00",
    currency: "THB",
    idempotencyKey: UUID().uuidString.lowercased(),
    callback: ReservepayWalletCallback<NSString>(
        onSuccess: { transferId in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)

ReservepayWalletSDK.companion.getInstance().findTransfer(
    transferId: "TRANSFER_ID",
    callback: ReservepayWalletCallback<Transfer>(
        onSuccess: { transfer in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)
```

### Programmatic APIs — transactions & Thai QR

```swift
ReservepayWalletSDK.companion.getInstance().getTransactions(
    walletId: "WALLET_ID",
    before: nil,
    after: nil,
    perPage: "10",
    callback: ReservepayTransactionsCallback(
        onSuccess: { page in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)

ReservepayWalletSDK.companion.getInstance().processThaiQR(
    payload: qrPayloadString,
    callback: ReservepayPromptpayCallback(
        onSuccess: { promptPay in },
        onFailed: { error in },
        onLoading: { _ in }
    )
)
```

---

## Errors

Handle **`onFailed`** on callbacks ( **`NSError`** ) and **`onError`** on **`verifyLiveness`**.
Structured API failures may surface as **`ReservepayWalletException`**. *
*`AuthenticationRequiredException`** means the user must complete **`startAuthentication`** first.

Check **`Environment.production`** vs **`Environment.development`** if requests fail against the
wrong API
host.
