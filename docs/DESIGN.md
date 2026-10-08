# 🎨 Padma — Design System & UI/UX Guidelines

> Complete design system and interface specification for **Padma (পদ্মা)**. This document acts as the definitive source of truth for color tokens, typography scales, component anatomy, spacing, and micro-interactions.

---

## 1. Brand Identity & Design Philosophy

- **Name**: Padma (পদ্মা) — inspired by the mighty river of Bangladesh, symbolizing constant motion, reliability, and connection.
- **Tagline**: *Never miss your bus.*
- **Sub-label**: *AUST Bus Companion & Campus Hub*
- **Visual Personality**: High-agency, precise, community-centric, dark-mode native, and glanceable under bright outdoor sunlight.
- **Inspiration**: A fusion of Discord's rich hierarchy (server rails, channel drawers, badge identifiers) and elite real-time transit telemetry interfaces.

---

## 2. Color System & Design Tokens

Padma utilizes a curated, accessible color palette optimized for dark OLED displays and high-contrast daytime visibility.

### Dark Theme Palette (Primary Default)

| Token Key | HEX Code | Preview / Visual Role | Usage |
| :--- | :--- | :--- | :--- |
| `surfaceLowest` | `#0E1013` | Deep Background | Scaffold canvas & underlying map frame |
| `surface` | `#16181D` | Primary Surface | Main cards, app bars, modal sheets, drawer |
| `surfaceElevated` | `#1F222A` | Elevated Surface | Active pills, nested containers, ETA boxes |
| `borderLine` | `#2A2E39` | Subtle Border | 1px clean dividing lines & card strokes |
| `primaryTeal` | `#14B8A6` | Primary Accent | Active route lines, primary buttons, links |
| `primaryTealContainer` | `rgba(20,184,166,0.18)`| Soft Accent | Badges, highlighted list rows, tag containers |
| `busAmber` | `#F59E0B` | Transit Accent | Bus icon markers, speedometer, ETA countdowns |
| `busAmberContainer`| `rgba(245,158,11,0.15)`| Soft Transit | Bus avatar container, route pill background |
| `urgentRed` | `#EF4444` | Emergency | Blood requests, breakdown alerts, error states |
| `successGreen` | `#10B981` | Positive State | On-time status, active live beacon dot |
| `textPrimary` | `#F8FAFC` | Primary Text | Headings, bus names, key metrics |
| `textSecondary` | `#94A3B8` | Secondary Text | Subtitles, stop names, body text |
| `textMuted` | `#64748B` | Muted Text | Timestamps, vehicle plates, labels |

### Semantic Role Badges

| Role | Badge Color | Background Tint |
| :--- | :--- | :--- |
| **Admin** | `#8B5CF6` (Vibrant Purple) | `rgba(139,92,246,0.18)` |
| **Driver / Staff** | `#14B8A6` (Padma Teal) | `rgba(20,184,166,0.18)` |
| **Verified Student** | `#38BDF8` (Sky Blue) | `rgba(56,189,248,0.18)` |
| **Blood Donor** | `#EF4444` (Urgent Red) | `rgba(239,68,68,0.18)` |

---

## 3. Typography Scale

The typography scale is designed to render crisply across standard English and Bengali fonts (e.g. *Inter* and *Hind Siliguri* / *Noto Sans Bengali*).

```
Display Large   : 28px • SemiBold (700) • Tracking -0.5
Title Medium    : 18px • SemiBold (700) • Headings & Route Names
Body Primary    : 14px • Regular  (400) • Chat messages & stop titles
Body Secondary  : 12px • Medium   (500) • Status pills, timestamps
Caption / Micro : 10px • SemiBold (600) • Badges, plate numbers, ETA labels
```

---

## 4. Spacing & Elevation

Padma follows a strict **4pt / 8pt spatial grid**:

- **Corner Radii**:
  - Buttons & Inputs: `10px` – `12px`
  - Cards & Containers: `16px` – `18px`
  - Bottom Sheets & Modals: `24px` top corners
  - Badges & Status Pills: `999px` (Full Pill)
- **Elevation Philosophy**: Prioritize 1px border outlines (`#2A2E39`) and subtle background color layering rather than heavy blurry drop-shadows.

---

## 5. Key Component Specifications

### 1. Live Bus Info Card
Located directly beneath the map on the Tracker screen:
- **Vehicle Identifier**: Bus icon in amber container, route title, approaching stop, and license plate.
- **Dynamic ETA Box**: Large teal countdown numeral + `MIN ETA` caption.
- **One-Tap Action**: A full-width primary button **[ Message ]** with a chat bubble icon that instantly routes to the campus `#general` channel.

```
┌────────────────────────────────────────────────────────┐
│  [🚌]  Bus 1 (Mirpur Route)                  ┌──────┐  │
│        Approaching Agargaon                  │  14  │  │
│        Plate: Dhaka Metro-Cha 11-4589        │MIN ETA│ │
│                                              └──────┘  │
├────────────────────────────────────────────────────────┤
│  [💬 Message]                                          │
└────────────────────────────────────────────────────────┘
```

### 2. Discord-Style Sliding Navigation Drawer
- **Server Header**: "PADMA // AUST CAMPUS TRANSIT" with active status beacon.
- **Section Grouping**:
  - `CHANNELS`: `#general`, `#announcements`, `#schedule`, `#lost-and-found`
  - `BUS TELEMETRY`: `#bus-1-mirpur`, `#bus-2-uttara`, `#bus-3-motijheel`
  - `EMERGENCY`: `🩸 blood-requests`
- **Active Channel Indicator**: Left teal bar with rounded highlighted background container.

### 3. Blood Request Emergency Card
- Prominent red blood group tag (e.g., `A+`, `O-`).
- Required units, patient location, and hospital details.
- Action triggers: "I Can Donate" and direct contact dialer.

---

## 6. Accessibility & Multi-Language Support

1. **Color Blindness Safe**: Status chips always combine color with an explicit semantic icon and text (e.g., green dot + checkmark + "On Time").
2. **Minimum Touch Targets**: Every interactive button and pill adheres to a minimum `48x48dp` tap area.
3. **Bangla Text Tolerant**: Bengali script has taller ascenders and descenders; all card paddings and line-heights are calculated with flexible container constraints.
