# 🏗️ Padma — Software Architecture & Technical Design

> Technical architecture, code organization, state management paradigms, and data flow pipelines for **Padma**.

---

## 1. Architectural Pattern: Clean MVVM

Padma is built on a decoupled, testable **Model-View-ViewModel (MVVM)** pattern with clear boundaries between UI, Domain Logic, and Data Ingestion:

```mermaid
graph TD
    subgraph Presentation Layer [UI Layer]
        V[Views / Screens] -->|Listens to| VM[ChangeNotifier ViewModels]
        V -->|User Interactions| VM
    end

    subgraph Domain Layer [Business Logic]
        VM -->|Invokes Commands| R[Repositories]
        VM -->|Consumes| Models[Domain Models & Entities]
    end

    subgraph Data Layer [Data & Infrastructure]
        R -->|Fetches / Subscribes| Services[Location / API Services]
        R -->|Reads / Writes| MockDB[Mock Data Store / Firestore]
        Services --> TelemetryStream[GPS Beacon Stream / WebSocket]
    end
```

---

## 2. Directory Structure

```
padma/
├── lib/
│   ├── main.dart                      # App entry point & MultiProvider initialization
│   │
│   ├── core/                          # 🌐 Core Infrastructure & Cross-Cutting Concerns
│   │   ├── config/                    # Global app configuration (Map bounds, zoom levels)
│   │   ├── l10n/                      # ARB localization files & generated classes
│   │   ├── theme/                     # AppTheme, AppColors, AppSpacing, typography
│   │   ├── utils/                     # Formatters, validators, date helpers
│   │   └── widgets/                   # Reusable UI components (NextStopCard, Badges, Chips)
│   │
│   ├── data/                          # 📦 Data Layer (Models, Repositories, Mock Data)
│   │   ├── mock/                      # Initial mock seeds for AUST buses, users, channels
│   │   ├── models/                    # Data transfer & domain entity classes
│   │   ├── repositories/              # Concrete data repositories (Auth, Transit, Chat, Emergency)
│   │   └── services/                  # GPS mock service & device stream providers
│   │
│   ├── features/                      # 🚀 Isolated Domain Modules
│   │   └── live_bus/                  # Live telemetry, GPS beacon simulation, and vector map screen
│   │       ├── data/                  # Mock GPS service & waypoint polylines
│   │       ├── domain/                # SharingStatus & BusLocation entity models
│   │       └── presentation/          # LiveBusViewModel, Map controls, LiveBusMapScreen
│   │
│   └── ui/                            # 🎨 Feature Presentation Modules
│       ├── core/                      # UI theme tokens & shared visual utilities
│       └── features/                  # App Views & ViewModels
│           ├── auth/                  # Sign In, Sign Up, Verification
│           ├── tracker/               # Live Transit Map, Route Switcher, Stop Timeline
│           ├── channels/              # Discord Drawer, General Chat, Telemetry Feeds, Requests
│           ├── profile/               # Student ID profile & donor preferences
│           ├── notifications/         # Real-time alerts feed & broadcast announcements
│           └── home/                  # Main shell Scaffold with bottom navigation
│
├── docs/                              # 📚 Comprehensive Documentation Suite
├── test/                              # 🧪 Unit, Widget, and Navigation Test Suite
└── pubspec.yaml                       # Dependencies & Flutter asset definitions
```

---

## 3. State Management: Provider & ViewModels

Padma utilizes Flutter's standard `Provider` / `ChangeNotifier` ecosystem for state propagation:

```mermaid
classDiagram
    class TrackerViewModel {
        +List~BusRoute~ availableRoutes
        +BusRoute selectedRoute
        +int currentEtaMinutes
        +int currentSpeed
        +void selectRoute(String routeId)
        +void updateEta(int minutes)
    }

    class LiveBusViewModel {
        +SharingStatus status
        +BusLocation? currentLocation
        +bool isLive
        +String remainingSessionFormatted
        +void startSharing()
        +void stopSharing()
        +void tick()
    }

    class ChannelsViewModel {
        +List~ChatMessage~ generalMessages
        +List~ChatMessage~ mirpurBusMessages
        +List~EmergencyRequest~ bloodRequests
        +void sendGeneralMessage(String text)
        +void addBloodRequest(EmergencyRequest req)
    }

    class AuthViewModel {
        +UserProfile? currentUser
        +bool isAuthenticated
        +void signIn(String email, String pass)
        +void signOut()
    }

    TrackerViewModel --|> ChangeNotifier
    LiveBusViewModel --|> ChangeNotifier
    ChannelsViewModel --|> ChangeNotifier
    AuthViewModel --|> ChangeNotifier
```

### MultiProvider Injection at Root (`lib/main.dart`):
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ChangeNotifierProvider(create: (_) => TrackerViewModel()),
    ChangeNotifierProvider(create: (_) => LiveBusViewModel()),
    ChangeNotifierProvider(create: (_) => ChannelsViewModel()),
  ],
  child: const PadmaApp(),
)
```

---

## 4. Real-Time Telemetry Pipeline

```mermaid
sequenceDiagram
    participant MockGPS as MockDeviceLocationService
    participant LiveVM as LiveBusViewModel
    participant UI as PadmaLiveMapWidget
    participant Map as FlutterMap Controller

    MockGPS->>LiveVM: Stream<BusLocation> (1 Hz Periodic Tick)
    LiveVM->>LiveVM: Compute speed, heading & distance progress
    LiveVM->>UI: notifyListeners() with updated coordinates
    UI->>Map: Linear Marker Interpolation (animate to new LatLng)
    UI->>UI: Update Speedometer Pill & ETA Countdown Box
```

### Map Layer Stack:
1. **Base Raster Layer**: CartoDB Dark Matter tiles via `TileLayer` (`https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}@2x.png`).
2. **Route Polyline Layer**: Fixed coordinates connecting AUST campus to route terminals (Mirpur, Uttara, Motijheel).
3. **Animated Bus Marker Layer**: Live pulsing GPS dot with heading rotation and bus icon.
4. **Stops & Checkpoints Layer**: Interactive stop nodes with ETA labels and arrival progress.

---

## 5. Security & Permission Architecture

| Layer | Policy | Enforcement |
| :--- | :--- | :--- |
| **Authentication** | Student email verification (e.g. `@aust.edu`). | `AuthRepository` session guard |
| **Channel Write Access** | `#announcements` write-locked to Admin; `#general` open to all verified riders. | `ChannelDrawer` and message composer guard |
| **GPS Beacon Control** | Only authorized drivers or demo controllers can broadcast GPS coordinates. | `DemoControlPanel` / `SharingStatus` state check |
