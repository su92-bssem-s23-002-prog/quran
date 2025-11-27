# Social Authentication Setup Guide

## Overview
This guide walks you through configuring Google and Facebook authentication for your Quran app in Firebase Console and platform-specific settings.

---

## 🔥 Firebase Console Setup

### Enable Authentication Providers

1. **Go to Firebase Console**
   - Visit https://console.firebase.google.com
   - Select your project: `quran-60c14`

2. **Navigate to Authentication**
   - Click "Authentication" in the left sidebar
   - Go to "Sign-in method" tab

### Google Sign-In Configuration

3. **Enable Google Provider**
   - Click on "Google" in the provider list
   - Toggle "Enable" switch
   - **Project support email**: Select your email from dropdown
   - Click "Save"

4. **Get OAuth Client ID (for Web)**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Select project `quran-60c14` (or your Firebase project)
   - Navigate to: APIs & Services > Credentials
   - You'll see an OAuth 2.0 Client ID created by Firebase
   - **Note down the Web client ID** (ends with `.apps.googleusercontent.com`)

### Facebook Sign-In Configuration

5. **Create Facebook App**
   - Go to [Facebook Developers](https://developers.facebook.com)
   - Click "My Apps" > "Create App"
   - Select "Consumer" as app type
   - App name: `Quran App` (or your preferred name)
   - App contact email: Your email
   - Click "Create App"

6. **Get Facebook App Credentials**
   - In Facebook App Dashboard, go to Settings > Basic
   - **Note down:**
     - App ID (e.g., `123456789012345`)
     - App Secret (click "Show" button)

7. **Enable Facebook Provider in Firebase**
   - Back in Firebase Console > Authentication > Sign-in method
   - Click on "Facebook"
   - Toggle "Enable" switch
   - **App ID**: Paste your Facebook App ID
   - **App secret**: Paste your Facebook App Secret
   - **Copy the OAuth redirect URI** (looks like: `https://quran-60c14.firebaseapp.com/__/auth/handler`)
   - Click "Save"

8. **Configure Facebook App OAuth Settings**
   - Back in Facebook App Dashboard
   - Go to "Facebook Login" > Settings (in left sidebar)
   - Add to "Valid OAuth Redirect URIs":
     - Paste the Firebase OAuth redirect URI you copied
   - Click "Save Changes"

9. **Make Facebook App Live**
   - In Facebook App Dashboard, toggle app from "Development" to "Live" mode
   - This is in the top bar (App Mode switch)

---

## 📱 Platform-Specific Configuration

### Android Configuration

10. **Add SHA-1 Fingerprint** (Required for Google Sign-In)

    ```powershell
    # Get debug SHA-1
    cd android
    .\gradlew signingReport
    ```

    - Look for "SHA1" under "Variant: debug"
    - Copy the SHA-1 fingerprint (format: `AA:BB:CC:...`)

11. **Add SHA-1 to Firebase**
    - Firebase Console > Project Settings > Your apps
    - Find your Android app (com.example.quran)
    - Scroll to "SHA certificate fingerprints"
    - Click "Add fingerprint"
    - Paste SHA-1 fingerprint
    - Click "Save"

12. **Download Updated google-services.json**
    - After adding SHA-1, download the updated `google-services.json`
    - Replace `android/app/google-services.json` with the new file

13. **Add Facebook App ID to Android**
    
    Create/update `android/app/src/main/res/values/strings.xml`:
    ```xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <string name="app_name">Quran</string>
        <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
        <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    </resources>
    ```

    Update `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <application>
        <!-- ... existing code ... -->
        
        <!-- Facebook Configuration -->
        <meta-data 
            android:name="com.facebook.sdk.ApplicationId" 
            android:value="@string/facebook_app_id"/>
        
        <activity 
            android:name="com.facebook.FacebookActivity"
            android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
            android:label="@string/app_name" />
        
        <activity
            android:name="com.facebook.CustomTabActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="@string/fb_login_protocol_scheme" />
            </intent-filter>
        </activity>
    </application>
    ```

### iOS Configuration (if targeting iOS)

14. **Download GoogleService-Info.plist**
    - Firebase Console > Project Settings > Your apps
    - Add iOS app or download from existing iOS app
    - Place in `ios/Runner/GoogleService-Info.plist`

15. **Update Info.plist for Google Sign-In**
    
    Add to `ios/Runner/Info.plist`:
    ```xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
                <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>fbYOUR_FACEBOOK_APP_ID</string>
            </array>
        </dict>
    </array>
    <key>FacebookAppID</key>
    <string>YOUR_FACEBOOK_APP_ID</string>
    <key>FacebookDisplayName</key>
    <string>Quran</string>
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>fbapi</string>
        <string>fb-messenger-share-api</string>
        <string>fbauth2</string>
        <string>fbshareextension</string>
    </array>
    ```

### Web Configuration

16. **Configure Web OAuth Client**
    
    Update `web/index.html` - add before `</head>`:
    ```html
    <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
    ```

17. **Add Authorized Domains**
    - Firebase Console > Authentication > Settings tab
    - Scroll to "Authorized domains"
    - Add your localhost and production domains:
      - `localhost`
      - `yourapp.web.app` (if using Firebase Hosting)

---

## ✅ Testing Checklist

### Test Google Sign-In

- [ ] Tap "Continue with Google" button
- [ ] Google account picker appears
- [ ] Select an account
- [ ] User is signed in and redirected to HomeScreen
- [ ] User's name/email appears in the app

**Troubleshooting:**
- **Error "API not enabled"**: Enable Google+ API in Google Cloud Console
- **Error "12501"**: SHA-1 fingerprint not added or wrong
- **Nothing happens**: Check OAuth client ID configuration

### Test Facebook Sign-In

- [ ] Tap "Continue with Facebook" button
- [ ] Facebook login dialog appears (web view or app)
- [ ] Enter Facebook credentials
- [ ] Approve permissions
- [ ] User is signed in and redirected to HomeScreen

**Troubleshooting:**
- **Error "App not setup"**: Facebook App ID not configured correctly
- **Error "Invalid OAuth redirect URI"**: Check Firebase redirect URI is added to Facebook App
- **App in development mode**: Make app "Live" in Facebook Dashboard
- **Error "MISSING_CLIENT_ID"**: Add facebook_app_id to strings.xml

### Test Account Linking

- [ ] Create account with email/password
- [ ] Sign out
- [ ] Sign in with Google using same email
- [ ] Should see error: "An account already exists with this email"
- [ ] Verify account linking scenarios work as expected

---

## 🔐 Security Best Practices

1. **Never commit sensitive credentials**
   - Keep `.env` file with API keys in `.gitignore`
   - Facebook App Secret should only be in Firebase Console

2. **Use different Facebook apps for dev/prod**
   - Development app for testing
   - Production app for live users

3. **Restrict API keys**
   - Google Cloud Console > Credentials
   - Edit API key > Set application restrictions
   - Add Android package name and SHA-1
   - Add iOS bundle ID

4. **Monitor authentication activity**
   - Firebase Console > Authentication > Users
   - Check for unusual sign-in patterns
   - Review provider-linked accounts

---

## 📚 Package Documentation

- **google_sign_in**: https://pub.dev/packages/google_sign_in
- **flutter_facebook_auth**: https://pub.dev/packages/flutter_facebook_auth
- **Firebase Auth**: https://firebase.google.com/docs/auth/flutter/start

---

## 🆘 Common Errors Reference

| Error | Solution |
|-------|----------|
| `PlatformException(sign_in_failed)` | Check SHA-1 fingerprint, enable Google Sign-In API |
| `ERROR_MISSING_GOOGLE_AUTH` | Download updated google-services.json after adding SHA-1 |
| `Facebook login failed` | Verify App ID/Secret in Firebase, check OAuth redirect URI |
| `account-exists-with-different-credential` | User trying to link same email with different providers |
| `invalid-credential` | Expired or malformed OAuth token |
| `User cancelled sign-in` | User closed Google/Facebook dialog - normal behavior |

---

## ✨ Next Steps

After completing this setup:

1. **Test thoroughly** on all platforms you're targeting
2. **Add analytics** to track sign-in success/failure rates
3. **Implement account linking** to merge multiple sign-in methods for same email
4. **Add profile completion screen** for social sign-in users (collect additional info)
5. **Handle edge cases**: Network errors, token expiration, account deletion

---

**Setup completed!** Your Google and Facebook authentication should now be fully functional. 🎉
