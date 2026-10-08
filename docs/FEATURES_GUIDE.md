# 🚀 Padma — Features & Functional Guide

> In-depth breakdown of every feature, user flow, and interaction model in **Padma**.

---

## 1. Feature Map

Padma is organized into 5 primary bottom navigation modules accessible from the unified main shell:

```
PADMA MAIN SHELL
├── 1. 🗺️ Tracker (Default Transit Map & HUD)
├── 2. 💬 Channels (Discord-Style Drawer & Feeds)
├── 3. 🩸 Requests (Emergency Blood Hub)
├── 4. 🔔 Alerts (Broadcast Notifications)
└── 5. 👤 Profile (Student ID & Donor Settings)
```

---

## 2. Module Details

### 1. 🗺️ Live GPS Transit Tracker (`/tracker`)
- **Real-Time Vector Map**: Interactive MapLibre/CartoDB Dark Matter map centered on AUST campus (Tejgaon, Dhaka) and active route paths.
- **Dynamic Bus Marker**: Moving beacon displaying real-time speed, heading angle, and pulsing radius.
- **Top HUD Speedometer**: Glanceable KM/H live speed indicator and route selector pill.
- **Floating Controls**:
  - `Recenter Button`: Smoothly snaps map camera to active bus GPS position.
  - `Fullscreen Map`: Expands map to a dedicated edge-to-edge view with advanced telemetry panels.
  - `Simulation Control FAB`: Opens demo control panel to start/stop live beacon, inject delays, or simulate motion.
- **Live Bus Info Card**:
  - Bus name, route, approaching stop name, and license plate.
  - Large dynamic ETA countdown (`MIN ETA`).
  - **Message Button**: Full-width button with chat icon that navigates directly to the campus `#general` discussion channel.
- **Route Timeline & Checkpoints**: Step-by-step stop progression indicating passed, current, and upcoming stops with distance percentages.

---

### 2. 💬 Discord-Style Channels & Community (`/channels`)
- **Sliding Navigation Drawer**:
  - Multi-category organization: *Information Channels*, *Bus Telemetry Feeds*, and *Emergency Hub*.
  - Visual lock indicators on read-only announcement channels.
  - Unread badge counters.
- **`#general` Channel**:
  - Public open forum for all verified AUST commuters.
  - Real-time message list with avatar, student department badge, and timestamp.
  - Interactive message composer with auto-scroll and immediate dispatch.
- **Bus Telemetry Channels** (`#bus-1-mirpur`, `#bus-2-uttara`, `#bus-3-motijheel`):
  - Filtered real-time chat dedicated to riders of a specific bus.
  - Automated system bot messages logging stop arrivals, departures, and delays.
- **`#announcements` Channel**:
  - Official channel with write-protection restricted to university administration.

---

### 3. 🩸 Emergency Blood Donation Hub (`/requests`)
- **Urgent Request Feed**:
  - Prominent red blood group tag (e.g., `A+`, `B+`, `O-`, `AB+`).
  - Hospital name, patient location, units required, and contact phone number.
- **Blood Group Filter Bar**:
  - Horizontal chip list allowing users to instantly filter requests by their own blood group.
- **"I Can Donate" Action**:
  - Instantly logs donor readiness and increments donor response counter.
- **Direct Phone Dialer**:
  - One-tap dial action initiating a cellular phone call to the patient's attendant.

---

### 4. 🔔 Alerts & Broadcasts (`/notifications`)
- Categorized notifications for:
  - **Transit Alerts**: Bus departure notices, route delays, breakdown warnings.
  - **Admin Broadcasts**: Campus schedule modifications and holiday route closures.
  - **Blood Matches**: Push notifications for matched donors based on registered blood type.

---

### 5. 👤 Student Profile & Settings (`/profile`)
- **Digital Student ID Card**:
  - Verified student name, ID number (e.g., `21.01.04.123`), department (CSE/EEE/ME/Civil/Arch), and university email.
- **Commuter Preferences**:
  - Default route selection (Mirpur / Uttara / Motijheel).
  - Favorite boarding stop for automated proximity alerts.
- **Blood Donor Toggle**:
  - Switch to make student's blood group visible to campus emergency search.
- **Language Switcher**:
  - Seamless toggle between English and Bengali (বাংলা).
