# Padma — Run on Physical Android Phone Guide

This guide walks you through connecting your Android phone, running Padma with live hot reload, and installing/sharing the debug APK.

---

## 1. One-Time Setup Checklist

### On Your Android Phone:
1. **Enable Developer Options**:
   - Open **Settings** → **About Phone** (or **About Device**).
   - Tap **Build Number** 7 times until you see `"You are now a developer!"`.
2. **Enable USB Debugging**:
   - Go back to **Settings** → **System** (or **Additional Settings**) → **Developer Options**.
   - Turn ON **USB Debugging**.
   - *(Xiaomi/Redmi/POCO users)*: Also turn ON **Install via USB** and **USB debugging (Security settings)**.
3. **Connect via USB**:
   - Plug your phone into your computer using a USB cable that supports data transfer.
   - When prompted on the phone, select **File Transfer / Android Auto** (MTP mode).
   - A popup will appear: `"Allow USB debugging from this computer?"`. Check **"Always allow from this computer"** and tap **Allow**.

### On Your Computer:
- Android SDK installed (`/home/arkosaha/Android/Sdk`).
- OpenJDK 21 installed.
- `adb` in PATH.

---

## 2. Running the App on Your Phone

### Step A: Verify Connected Device
Run in terminal:
```bash
adb devices -l
flutter devices
```
You should see your device name (e.g., `RF8M...` or `device`).

### Step B: Launch in Debug Mode (with Hot Reload)
```bash
flutter run
```
Or specify your device explicitly if multiple devices/emulators are connected:
```bash
flutter run -d <device-id>
```

### Hot-Reload Commands (in terminal while app is running):
- `r` : **Hot Reload** (instant UI update in sub-seconds)
- `R` : **Hot Restart** (re-initializes state and restarts app)
- `h` : List all available interactive commands
- `c` : Clear terminal screen
- `q` : Detach and quit

---

## 3. Wireless Debugging (Android 11+)

If you prefer testing without a USB cable:
1. Connect your phone and computer to the **same Wi-Fi network**.
2. On your phone: **Developer Options** → **Wireless Debugging** → Turn ON.
3. Tap **"Pair device with pairing code"**. Note the IP address, Port, and 6-digit Wi-Fi pairing code.
4. On your computer terminal:
   ```bash
   adb pair <IP>:<PORT>
   # Enter the 6-digit pairing code when prompted
   ```
5. Once paired, connect to the device:
   ```bash
   adb connect <IP>:<PORT>
   ```
6. Run `flutter devices` and `flutter run -d <IP:PORT>`.

---

## 4. Manual APK Installation & Sharing

### Build the Debug APK
```bash
flutter build apk --debug
```
The output APK is generated at:
```
build/app/outputs/flutter-apk/app-debug.apk
```
And copied to:
```
./dist/padma-debug.apk
```

### Install APK via ADB:
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Sharing with Friends:
- Share `dist/padma-debug.apk` via Google Drive, WhatsApp, Telegram, or Discord.
- Friends must enable: **Settings → Security / Apps → Install unknown apps / Allow from this source**.

---

## 5. Troubleshooting Matrix

| Issue | Cause | Fix |
|---|---|---|
| `List of devices attached (empty)` | Cable is charge-only or USB debugging is disabled | 1. Use data USB cable.<br>2. Toggle USB debugging OFF then ON in Developer Options.<br>3. Switch USB mode to "File Transfer".<br>4. Run `adb kill-server && adb start-server`. |
| `Device unauthorized` | Debugging prompt not accepted on phone | Unlock phone screen and tap **Allow** on the RSA key prompt. |
| `INSTALL_FAILED_USER_RESTRICTED` | MIUI / ColorOS / FuntouchOS security blocking USB installs | In Developer Options, enable **"Install via USB"**. |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Existing signature or package mismatch on device | Run `adb uninstall com.aust.padma` then re-run `flutter run` or `adb install`. |
| Gradle build hangs / locks | Daemon memory / stale locks | Run `cd android && ./gradlew --stop` and clean with `flutter clean`. |
| Map tiles not loading | Network permissions / User-Agent missing | Verified: `INTERNET` permission added in `AndroidManifest.xml` and `com.aust.padma` configured for OpenStreetMap tile requests. |

---

## 6. Quick Cheat Sheet

```bash
# Check device connection
adb devices -l
flutter devices

# Run on phone with hot reload
flutter run

# Build debug APK
flutter build apk --debug

# Install directly to connected phone
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# View real-time device Flutter logs
adb logcat | grep flutter
# (PowerShell on Windows: adb logcat | Select-String "flutter")

# Uninstall cleanly if needed
adb uninstall com.aust.padma
```
