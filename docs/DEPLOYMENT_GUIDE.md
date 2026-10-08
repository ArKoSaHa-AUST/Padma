# 📦 Padma — Deployment & Release Guide

> Production build instructions, Android APK/AAB packaging, signing procedures, and release distribution for **Padma**.

---

## 1. Android Build Targets

Padma supports building both standalone installable **APKs** and Google Play optimized **Android App Bundles (AAB)**.

### 1. Build Debug APK (For Testing & Sharing)
```bash
flutter build apk --debug
```
- Output location: `build/app/outputs/flutter-apk/app-debug.apk`

### 2. Build Release APK (Optimized & Shrunk)
```bash
flutter build apk --release --split-per-abi
```
- Generates separate optimized APKs for `armeabi-v7a`, `arm64-v8a`, and `x86_64` to minimize download size.
- Output location: `build/app/outputs/flutter-apk/`

### 3. Build Production Android App Bundle (AAB)
```bash
flutter build appbundle --release
```
- Output location: `build/app/outputs/bundle/release/app-release.aab`

---

## 2. Release Signing Configuration

To sign release builds for production:

1. Generate a keystore (if not already created):
```bash
keytool -genkey -v -keystore android/app/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias padma
```

2. Create `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=padma
storeFile=../app/key.jks
```

3. Ensure `key.properties` is included in `.gitignore` to prevent secret leakage.

---

## 3. Pre-Release Checklist

- [ ] Run `flutter analyze` — verify zero lint errors and zero warnings.
- [ ] Run `flutter test` — verify all unit, widget, and integration tests pass.
- [ ] Verify `pubspec.yaml` version number (e.g. `version: 1.0.0+1`).
- [ ] Verify Android permissions in `android/app/src/main/AndroidManifest.xml` (Internet, Location, Network State).
- [ ] Test on a physical low-end Android device to verify vector map performance and memory usage.
- [ ] Test language toggling between English and Bengali (বাংলা).
