# 🚌 Padma (পদ্মা) — AUST Campus Transit Tracker & Student Hub

> **Padma** is a modern, real-time campus transit tracking companion and community platform tailored specifically for the students, faculty, and administration of Ahsanullah University of Science and Technology (AUST). Built using **Flutter & Dart** with Clean MVVM Architecture and reactive Provider state management.

---

## 📚 Project Documentation Hub

All detailed technical documentation is organized in the [`docs/`](file:///media/arkosaha/Volume13/padma/docs/) directory:

| Document | Description |
| :--- | :--- |
| **[Admin Portal Manual](file:///media/arkosaha/Volume13/padma/docs/ADMIN_PANEL.md)** | Fleet command center, live GPS controls, AI announcement studio, and moderation. |
| **[Project Overview](file:///media/arkosaha/Volume13/padma/docs/PROJECT_OVERVIEW.md)** | Product vision, target users, problem statement, core value proposition & roadmap. |
| **[Design System](file:///media/arkosaha/Volume13/padma/docs/DESIGN.md)** | Color tokens, dark theme palette, typography scale, component specs & Bangla support. |
| **[Software Architecture](file:///media/arkosaha/Volume13/padma/docs/ARCHITECTURE.md)** | Layered Clean MVVM architecture, Provider ViewModels, telemetry pipeline & security. |
| **[Features & Functional Guide](file:///media/arkosaha/Volume13/padma/docs/FEATURES_GUIDE.md)** | Comprehensive guide to the Tracker, Discord-style Channels, Blood Hub, Alerts & Profile. |
| **[Data Models & Schemas](file:///media/arkosaha/Volume13/padma/docs/DATA_MODELS.md)** | Entity Relationship diagrams and detailed Dart model specifications. |
| **[Telemetry & Maps Engine](file:///media/arkosaha/Volume13/padma/docs/TELEMETRY_AND_MAPS.md)** | CartoDB / OSM vector mapping, waypoint polylines, GPS simulation & hardware roadmap. |
| **[Developer Guide](file:///media/arkosaha/Volume13/padma/docs/DEVELOPMENT_GUIDE.md)** | Environment setup, local running, testing gates (`flutter test`), and code standards. |
| **[Deployment & Release Guide](file:///media/arkosaha/Volume13/padma/docs/DEPLOYMENT_GUIDE.md)** | Android APK / AAB packaging, release signing, and deployment checklist. |
| **[Run on Physical Phone](file:///media/arkosaha/Volume13/padma/docs/RUN_ON_PHONE.md)** | Step-by-step instructions for USB & wireless debugging on physical Android devices. |

---

## 📁 Repository Structure

```
padma/
├── docs/                              # 📚 Comprehensive Documentation Suite
│   ├── ADMIN_PANEL.md                 # Admin portal, AI copilot & fleet controls
│   ├── PROJECT_OVERVIEW.md            # Vision, personas & roadmap
│   ├── DESIGN.md                      # UI tokens, typography & components
│   ├── ARCHITECTURE.md                # MVVM architecture & telemetry flow
│   ├── FEATURES_GUIDE.md              # Functional screen specifications
│   ├── DATA_MODELS.md                 # Entity models & ER diagrams
│   ├── TELEMETRY_AND_MAPS.md          # GPS simulation & map stack
│   ├── DEVELOPMENT_GUIDE.md           # Setup, workflows & testing
│   ├── DEPLOYMENT_GUIDE.md            # APK / AAB release builds
│   └── RUN_ON_PHONE.md                # Physical device debugging guide
│
├── lib/                               # 🎯 Complete Dart Application Codebase
│   ├── main.dart                      # App entry point & MultiProvider setup
│   ├── core/                          # Theme, config, l10n, widgets & utils
│   ├── data/                          # Models, mock services & repositories
│   ├── features/                      # Domain features (live_bus)
│   └── ui/                            # Presentation layer (tracker, channels, auth, etc.)
│
├── test/                              # 🧪 Unit & Widget Automated Test Suite
└── README.md                          # Master Project Readme
```

---

## 🚀 Quick Start

### 1. Prerequisites & Dependencies
```bash
flutter pub get
```

### 2. Verify Code Quality & Run Tests
```bash
flutter analyze
flutter test
```

### 3. Launch App
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android
```
