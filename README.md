# HangBug Mobile (Flutter Android Application)

Production-ready Flutter Android mobile application for **HangBug** — The Web Development & Software Engineering Quiz & Certification Platform.

Designed, structured, and compiled for Google Play Store release as a signed Android App Bundle (`.aab`).

---

## 🏛 Architecture Overview

```
                      +-----------------------------+
                      |     HangBug Android App     |
                      |   (Riverpod 2.6 + Dio 5.7)  |
                      +--------------+--------------+
                                     |
                         HTTPS REST API (TLS 1.3)
                                     |
                      +--------------v--------------+
                      |   Node.js / Express Server  |
                      |   (Vercel Production API)   |
                      +--------------+--------------+
                                     |
                                  Mongoose
                                     |
                      +--------------v--------------+
                      |      MongoDB Atlas DB       |
                      +-----------------------------+
```

> **Security Note:** The mobile app NEVER connects directly to MongoDB Atlas. All interactions flow through authenticated HTTPS REST endpoints with Bearer JWT tokens stored in encrypted Android Keystore via `flutter_secure_storage`.

---

## 🚀 Key Features

1. **Authentication & Session Persistence:**
   - JWT-based authentication (Login, Register, Logout).
   - Bi-directional token storage via `flutter_secure_storage` backed by Android EncryptedSharedPreferences / Keystore.
   - Automatic cold-start session restoration and background 401 token expiration handling.

2. **Dynamic Quiz Engine:**
   - Real-time quiz data loaded dynamically from the live backend database.
   - 4-option questions with timer, answered/unanswered progress tracking, and full question navigation modal.
   - Immediate server scoring and persistent result submission.

3. **Verifiable Certificates & QR Codes:**
   - 80%+ scores unlock official verified certificates.
   - In-app rendered certificates with live dynamic QR codes pointing to the HangBug verification web portal.
   - Native system sharing (`share_plus`) and clipboard copy.

4. **Interactive Dashboard:**
   - Total attempts, pass rate, average scores, and technology progress breakdown.
   - Recent quiz histories and quick resume shortcuts.

5. **Full Administrative Suite (Guarded by RBAC):**
   - Visible and accessible only to users with `role: "admin"`.
   - Analytics KPI dashboard with time-range filtering (`7d`, `30d`, `1y`).
   - Question bank management (create, search, filter, delete).
   - Category management (add technology tracks, delete tracks).
   - User account directory management.
   - AI Question Generator calling the backend generative engine.

6. **Google Play Store Policy Compliance:**
   - **Account Deletion Flow:** Settings $\rightarrow$ Delete Account & Data permanently deletes the account and all associated attempts from MongoDB.
   - **Data Safety Transparency:** In-app Privacy Policy and Terms of Service.
   - **Minimal Permissions:** Only `INTERNET` and `ACCESS_NETWORK_STATE`.

---

## 📁 Project Directory Structure

```
mobile/
├── android/
│   ├── app/
│   │   ├── build.gradle.kts       # Android app config (compileSdk 35, targetSdk 35)
│   │   ├── upload-keystore.jks    # Release signing keystore
│   │   └── src/main/
│   │       ├── AndroidManifest.xml # Minimal permissions & launcher config
│   │       └── kotlin/com/hangbug/app/MainActivity.kt
│   └── key.properties             # Keystore credentials (git-ignored)
├── lib/
│   ├── core/
│   │   ├── config/                # AppConfig (Base URL, versioning)
│   │   ├── constants/             # Colors, Strings, TextStyles, Endpoints
│   │   ├── network/               # ApiClient, Interceptors, Exceptions
│   │   ├── storage/               # SecureStorageService
│   │   ├── theme/                 # Light and Dark Material 3 themes
│   │   └── utils/                 # Validators, DateFormatter
│   ├── models/                    # Data models (User, Quiz, Certificate, Admin, etc.)
│   ├── providers/                 # Riverpod state providers
│   ├── repositories/              # Repository data layer
│   ├── routes/                    # GoRouter with authentication guards
│   ├── screens/                   # UI Screens (Auth, Home, Quiz, Results, Certs, Admin)
│   ├── services/                  # HTTP Service implementations
│   ├── widgets/                   # Reusable components (AppButton, Cards, States)
│   └── main.dart                  # Application entry point
├── pubspec.yaml                   # Dependencies & asset declarations
└── PLAY_CONSOLE_GUIDE.md          # Google Play Console publishing guide
```

---

## 🛠 Local Development & Commands

> **Important:** Always execute Flutter commands from within the `mobile/` directory:
> ```powershell
> cd d:\hangbug\mobile
> ```

### 1. Static Analysis
Run static analysis to verify code quality:
```powershell
flutter analyze
```

### 2. Run Test Suite
Execute unit and widget tests:
```powershell
flutter test
```

### 3. Run Locally (Emulator or USB Device)
```powershell
flutter run
```

### 4. Build Release App Bundle (.aab)
Compile a signed Android App Bundle ready for Google Play:
```powershell
flutter build appbundle --release
```
The resulting bundle is generated at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 🔐 Release Signing Information

- **Keystore File:** `mobile/android/app/upload-keystore.jks`
- **Key Alias:** `hangbug`
- **Keystore Configuration:** `mobile/android/key.properties`
- **Algorithm:** RSA 2048-bit with SHA-256
- **Validity:** 10,000 days (~27 years)
