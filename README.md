<div align="center">

# 🛡️ DoomGuard

### Take back your screen time.

A Flutter-based digital wellbeing app that helps you monitor screen time, build focus habits, and break the doomscrolling cycle — with real-time tracking, a Pomodoro-style focus timer, streaks, and a badge-based reward system.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](#)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](#license)

</div>

---

## Overview

Excessive, unregulated smartphone use — doomscrolling in particular — has been linked to poor sleep, reduced attention span, and lower productivity. **DoomGuard** tackles this with real-time usage analytics wrapped in a gamified experience, so building healthier screen habits feels rewarding instead of restrictive.

The app tracks per-app usage, sends smart notification nudges as limits are approached, and rewards consistent focus sessions and daily streaks through an achievement system — all backed by Firebase for secure, cross-device sync.

## ✨ Features

- 📊 **Real-time screen time tracking** — per-app usage breakdown with day/week/month views
- ⏱️ **Pomodoro-based focus timer** — Pomodoro (25m), Deep Work (50m), Flow (90m), and Quick (15m) presets
- 🔥 **Streak system** — tracks current and longest streaks, with a once-a-week streak freeze
- 🏆 **Badge & achievement system** — 8 unlockable badges based on real usage milestones
- 🔔 **Smart nudges** — tiered notifications for per-app limits, continuous sessions, and total screen time
- 🔒 **Strict Mode** — enforces usage restrictions during a user-defined wind-down window
- 🔑 **Google Sign-In** — Firebase Authentication with Cloud Firestore-backed persistence
- 📄 **Privacy-first onboarding** — one-time consent gate before any data collection

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3.3+ |
| State Management | Provider (`StreakState`, `UsageState`, `SettingsState`) |
| Navigation | `go_router` — `StatefulShellRoute` bottom nav (Home / Stats / Timer / Streaks / Settings) |
| Auth | Firebase Authentication (Google Sign-In) |
| Database | Cloud Firestore (user stats, cross-device sync) |
| Survey Backend | Supabase (`survey_responses` table, salted/hashed via `sync_surveys.py`) |
| Usage Tracking | Android `UsageStatsManager` |

## 🏗️ Architecture

- **State management** is handled entirely through `Provider`, split across dedicated state classes for streaks, usage stats, and settings.
- **Navigation** uses a `StatefulShellRoute` from `go_router` to preserve tab state across the five main sections.
- **Data persistence** is local-first (`SharedPreferences`) with a sync layer to Cloud Firestore, so progress survives app reinstalls and carries across devices.
- **Streak logic** computes the day-difference between the last active date and today — a gap of exactly one day triggers an automatic streak freeze (once per week); anything longer resets the streak.
- **Badges** are computed dynamically from five underlying stats rather than stored as flags, so they stay correct even after a fresh install and data rehydration.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- A Firebase project with Authentication (Google provider) and Cloud Firestore enabled
- An Android device or emulator running Android 8.0+ (tested on Android 16 / API 36)

### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/doomguard.git
cd doomguard

# Install dependencies
flutter pub get

# Add your Firebase config
#   - Place google-services.json in android/app/

# Run the app
flutter run
```

## 📂 Project Structure

```
doomguard/
├── lib/
│   ├── services/          # user_stats_service.dart, notification/nudge logic
│   ├── state/              # streak_state.dart, usage_state.dart, settings_state.dart
│   ├── screens/             # Home, Stats, Timer, Streaks, Settings
│   └── main.dart
├── android/
├── screenshots/
└── README.md
```

## 🎓 Project Background

DoomGuard was developed as an internship project by a team of second-year B.Tech students (Artificial Intelligence and Data Science) at KJ Somaiya School of Engineering, under faculty guidance, over an eight-week development cycle covering the full SDLC — from requirements gathering to final deployment testing on a physical Android device.

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
<sub>Built with Flutter & Firebase · DoomGuard v1.0</sub>
</div>
