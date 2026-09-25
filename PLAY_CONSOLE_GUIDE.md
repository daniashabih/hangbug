# Google Play Console Submission Guide for HangBug

This document contains step-by-step instructions to publish the **HangBug** Android application on the **Google Play Store** via Google Play Console.

---

## 1. Prerequisites

- A registered **Google Play Developer Account** (one-time \$25 fee at [play.google.com/console](https://play.google.com/console)).
- The signed release Android App Bundle (`app-release.aab`) located at:
  `d:\hangbug\mobile\build\app\outputs\bundle\release\app-release.aab`
- Upload keystore credentials:
  - **Keystore path:** `mobile/android/app/upload-keystore.jks`
  - **Key alias:** `hangbug`
  - **Password:** Configured in `mobile/android/key.properties`

---

## 2. Create the Application in Play Console

1. Navigate to [Google Play Console](https://play.google.com/console).
2. Click **Create app** (top-right corner).
3. Fill in basic details:
   - **App name:** `HangBug - Web Tech Quizzes & Certificates`
   - **Default language:** English (United States) – en-US
   - **App or game:** App
   - **Free or paid:** Free
4. Accept the **Developer Program Policies** and **US export laws**.
5. Click **Create app**.

---

## 3. Store Listing Setup

Navigate to **Grow $\rightarrow$ Store presence $\rightarrow$ Main store listing**:

### Text Metadata
- **App name:** `HangBug - Web Tech Quizzes & Certificates` (Max 30 characters)
- **Short description:**
  ```text
  Test your software engineering skills with tech quizzes and earn certificates!
  ```
- **Full description:**
  ```markdown
  HangBug is the premier platform for web developers, software engineers, and programming students to validate their technical knowledge and earn verifiable industry certificates.

  🚀 KEY FEATURES:
  • Multi-Category Tech Quizzes: Test your expertise across JavaScript, TypeScript, React, Node.js, Python, Docker, CSS, and modern web frameworks.
  • Verified Certificates: Score 80% or higher to earn an official HangBug certificate featuring a cryptographically verifiable QR code.
  • In-Depth Progress Tracking: Monitor your passing rates, quiz attempt streaks, and skill mastery breakdown.
  • Timed Assessments: Realistic quiz environments designed to sharpen technical interview readiness.
  • Safe & Secure: Minimal permissions, TLS 1.3 encrypted data transit, and complete privacy control.

  Whether you are preparing for coding interviews, reinforcing your bootcamp curriculum, or proving your developer skills, HangBug gives you the credentials to stand out.
  ```

### Graphic Assets
- **App Icon:** 512 x 512 px PNG (32-bit with alpha). Use `assets/images/icon.png`.
- **Feature Graphic:** 1024 x 500 px JPEG or 24-bit PNG (no alpha).
- **Phone Screenshots:** At least 2 screenshots (16:9 or 9:16 aspect ratio, min 1080px).
- **7-inch Tablet & 10-inch Tablet Screenshots:** (Optional for phone-first release).

---

## 4. Policy & App Content Declarations

Navigate to **Policy and programs $\rightarrow$ App content**:

### A. Privacy Policy
- Provide Privacy Policy URL: `https://hangbug.vercel.app/privacy`

### B. App Access (Crucial for Google Reviewers)
Because HangBug requires authentication to take quizzes and issue certificates, provide test account credentials for the Google Play review team:
- Select: **"All or some functionality is restricted"**
- Click **Add instructions**:
  - **Title:** `Reviewer Test Account`
  - **Username / Email:** `reviewer@hangbug.com` (or create a dedicated account)
  - **Password:** `HangbugTest2026!`
  - **Explanation:** `Full access to user dashboard, tech quizzes, certificate generation, and profile settings.`

### C. Ads
- Select: **"No, my app does not contain ads"**.

### D. Content Rating (IARC Questionnaire)
1. Enter your contact email.
2. Select category: **"Utility, Productivity, Communication, or Other"** / **"Education"**.
3. Answer questions regarding violence, sexuality, offensive language, and substance use: Select **"No"** to all.
4. Summary rating will yield **Everyone / PEGI 3**.

### E. Target Audience & Content
- Target age group: Check **13-15**, **16-17**, and **18 and over**.
- Appeal to children: **"No"**.

### F. News Apps
- Select: **"No"**.

### G. COVID-19 Contact Tracing & Status
- Select: **"My app is not a COVID-19 contact tracing or status app"**.

### H. Data Safety Section (Mandatory)
Google Play requires strict disclosure of all collected data:
1. **Does your app collect or share any user data?**
   $\rightarrow$ Select **Yes**.
2. **Is all user data encrypted in transit?**
   $\rightarrow$ Select **Yes** (Transmitted over HTTPS TLS 1.3).
3. **Do you provide a way for users to request that their data be deleted?**
   $\rightarrow$ Select **Yes** (HangBug provides in-app deletion under Settings $\rightarrow$ Delete Account & Data, as well as web/email deletion requests).
4. **Data Types Collected:**
   - **Personal Info $\rightarrow$ Name:**
     - Collected: Yes
     - Shared: No
     - Processed ephemerally: No
     - Required: Yes
     - Purpose: **App functionality**, **Account management** (Printed on earned certificates).
   - **Personal Info $\rightarrow$ Email address:**
     - Collected: Yes
     - Shared: No
     - Processed ephemerally: No
     - Required: Yes
     - Purpose: **App functionality**, **Account management** (Sign-in and recovery).
   - **App activity $\rightarrow$ In-app actions:**
     - Collected: Yes (Quiz attempts, responses, scores)
     - Shared: No
     - Purpose: **App functionality**, **Analytics** (Dashboard performance stats).

### I. Government Apps
- Select: **"No"**.

### J. Financial Features
- Select: **"My app doesn't provide any financial features"**.

---

## 5. Upload Release App Bundle (.aab)

1. In Play Console, navigate to **Release $\rightarrow$ Production** (or **Testing $\rightarrow$ Internal testing** for initial testing).
2. Click **Create new release**.
3. Under **App bundles**, upload:
   `app-release.aab` (or `build\app\outputs\bundle\release\app-release.aab`)
4. Enter **Release name:** `1.1.0 (4)`
5. Enter **Release notes (en-US):**
   ```text
   What's new in HangBug 1.1.0:
   - Guest Mode: Try quizzes and explore categories immediately without mandatory sign-up
   - Local progress storage and seamless guest data transition upon login
   - Sleek new floating navigation bar for smoother in-app browsing
   - Upgraded Android SDK 36 target and R8 code optimization for faster startup
   ```
6. Click **Next**, review release summary, and click **Save**.
7. Submit for review!

---

## 6. Keeping the Upload Keystore Safe

The keystore `upload-keystore.jks` and `key.properties` contain the cryptographic keys used to sign your app.
> **WARNING:** If you lose this keystore file before enabling Google Play App Signing, you will not be able to push updates to the same app listing.
> - Google Play automatically manages app signing with **Play App Signing** once your first `.aab` is uploaded.
> - Always back up `upload-keystore.jks` in a secure password manager or encrypted private drive.
