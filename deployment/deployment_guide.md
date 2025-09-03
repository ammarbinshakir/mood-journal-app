# Deployment Guide

This document outlines the steps for deploying the Mood Journal app to both iOS and Android platforms.

## iOS Deployment (TestFlight)

### Prerequisites

- Apple Developer account ($99/year)
- Xcode installed on a Mac
- App Store Connect access
- App registered on App Store Connect

### Steps

1. **Prepare App for Release**

   ```bash
   flutter build ios --release
   ```

2. **Open Xcode Project**

   ```bash
   cd ios
   open Runner.xcworkspace
   ```

3. **Configure Signing & Capabilities**
   - In Xcode, select the Runner project in the navigator
   - Select the "Runner" target
   - Go to the "Signing & Capabilities" tab
   - Select your team and ensure your Bundle Identifier matches what's registered on App Store Connect

4. **Create Archive**
   - In Xcode, select "Product" -> "Archive"
   - After archiving completes, the Organizer window will appear

5. **Upload to TestFlight**
   - In the Organizer, select your archive and click "Distribute App"
   - Select "App Store Connect"
   - Follow the prompts to upload to TestFlight
   - Wait for Apple to process your build (usually 15-30 minutes)

6. **Distribute to Testers**
   - Go to App Store Connect website
   - Navigate to your app -> TestFlight
   - Add testers either by email or by creating a public link
   - Select the build to distribute to testers

## Android Deployment (Google Play Internal Testing)

### Prerequisites

- Google Play Developer account ($25 one-time fee)
- App registered on Google Play Console
- Key store for signing the app

### Steps

1. **Create a Key Store**
   - If you don't already have one:
     ```bash
     keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
     ```

2. **Configure Gradle for Release**
   - Add the following to `android/key.properties` (create if it doesn't exist):
     ```
     storePassword=<password>
     keyPassword=<password>
     keyAlias=upload
     storeFile=<path-to-keystore>
     ```
   - Update `android/app/build.gradle` to reference the signing config

3. **Build Release AAB**
   ```bash
   flutter build appbundle --release
   ```

4. **Upload to Google Play Console**
   - Go to Google Play Console
   - Select your app -> Internal testing
   - Create a new release
   - Upload the AAB file from `build/app/outputs/bundle/release/app-release.aab`
   - Fill out release details
   - Save and review the release

5. **Add Testers**
   - Still in the Internal testing section
   - Add testers by email under "Testers"
   - Publish the release
   - Google will process the release (usually within minutes)
   - Testers will receive an email invitation to download the app

## Continuous Integration/Continuous Delivery

Our CI/CD pipeline is configured using GitHub Actions. It:
1. Builds the app
2. Runs tests
3. Creates release artifacts
4. Deploys to TestFlight and Google Play internal testing when a new tag is pushed

For details, see `.github/workflows/flutter.yml` in the project root.
