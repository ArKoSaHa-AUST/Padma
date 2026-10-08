# 🛠️ Padma — Developer Guide & Contributing

> Guidelines for setting up the local development environment, executing tests, running static analysis, and contributing to the codebase.

---

## 1. Prerequisites

- **Flutter SDK**: `>= 3.19.0` (Dart SDK `>= 3.3.0`)
- **Java**: OpenJDK 17 or 21
- **Android Studio / Android SDK**: Platform API 34+ and Build-Tools 34.0.0+
- **VS Code / Antigravity / Android Studio** with Flutter & Dart extensions.

---

## 2. Quick Setup

```bash
# 1. Clone repository
git clone https://github.com/your-org/padma.git
cd padma

# 2. Fetch dependencies
flutter pub get

# 3. Verify toolchain
flutter doctor -v
```

---

## 3. Running the App

### Debug Run (with instant Hot Reload):
```bash
# Target default connected device / emulator
flutter run

# Target Chrome for instant web verification
flutter run -d chrome

# Target connected Android phone
flutter run -d android
```

### Hot-Reload Shortcuts (Terminal):
- `r` : **Hot Reload** (Sub-second widget tree re-render)
- `R` : **Hot Restart** (State re-initialization)
- `q` : Quit debugging session

---

## 4. Testing & Code Quality Gates

Padma enforces 100% clean static analysis and comprehensive unit/widget test coverage before merging code.

### Run Static Analysis:
```bash
flutter analyze
```

### Run Automated Tests:
```bash
flutter test
```

### Test Suite Structure:
- `test/widget_test.dart`: End-to-end rendering and shell navigation tests.
- `test/auth_test.dart`: Authentication state transitions, sign-in validation, and session clearing tests.
- `test/tracker_test.dart`: Route switching, ETA computations, and live location updates.
- `test/channels_test.dart`: Message dispatching, channel switching, and emergency blood request filtering.
- `test/live_bus_widget_test.dart`: Map widget rendering and simulation controls.

---

## 5. Coding Standards & Best Practices

1. **Layer Separation**:
   - Views should never perform network I/O or mutate state directly; always invoke ViewModel methods.
   - Use `context.watch<T>()` for reactive UI rebuilds and `context.read<T>()` inside button callbacks.
2. **Theme Consistency**:
   - Never hardcode raw hex colors in widgets; use semantic tokens from `PadmaTheme` (e.g., `PadmaTheme.surface`, `PadmaTheme.primaryTeal`).
3. **Localization**:
   - Ensure new user-facing strings are added to both `lib/core/l10n/app_en.arb` and `lib/core/l10n/app_bn.arb`.
