# Daily Attendance & TA/DA Tracker App

## Project Description
The Daily Attendance & TA/DA Tracker is a mobile application designed for employees to seamlessly mark their daily work attendance and log TA/DA (Travel/Daily Allowance) claims. This app operates fully offline without any cloud backend dependencies, ensuring absolute privacy and on-device data persistence. It supports generating structured, color-coded PDF reports for attendance and exporting TA/DA claims as PDF and CSV files. The core business logic operates on a specific pay-month cycle running from the 26th of one month to the 25th of the next month.

## Features
- **Daily Attendance Marking**: Mark each day with statuses like Day Shift, Night Shift, On Leave, Weekend, Holiday, or Absent.
- **Pay-Month Cycle**: All calendar views, data grouping, and exports are structured around the company pay month (26th to 25th).
- **Calendar PDF Export**: Generate a color-coded PDF calendar grid with a legend, employee details, and month range.
- **TA/DA Tracking**: Add, edit, and delete multiple expense entries (purpose, amount, remarks) per day. Includes a monthly summary view with totals.
- **TA/DA Reports**: Export monthly TA/DA summaries to both PDF and CSV formats.
- **Local Authentication**: Simple login using Name and Employee ID. The device remembers the user across sessions using `shared_preferences`.
- **Fully Offline**: Data is stored locally on the device using SQLite. No internet connection is required for any feature.

## Tech Stack
- **Framework**: Flutter & Dart
- **State Management**: Riverpod (`flutter_riverpod`)
- **Local Database**: SQLite (`sqflite`)
- **PDF Generation**: `pdf` & `printing`
- **Data Export**: `csv` & `share_plus`
- **Local Persistence**: `shared_preferences`

## File Structure
```
lib/
├── app.dart              # Main application widget
├── main.dart             # Application entry point
├── database/             # SQLite database initialization and DAO classes
├── models/               # Data models (Attendance, TaDaEntry, etc.)
├── providers/            # Riverpod state management providers
├── screens/              # Application UI screens (Login, Home, TA/DA Summary, etc.)
├── theme/                # Global application theme, colors, and fonts
├── utils/                # Helper functions, constants, and PDF/CSV export logic
└── widgets/              # Reusable UI components
```

## Prerequisites
Before you begin, ensure you have met the following requirements:
- **Flutter SDK**: `^3.13.1` or newer installed on your machine.
- **Dart SDK**: Included with Flutter.
- **IDE**: Android Studio, Visual Studio Code, or Xcode (for iOS builds) with Flutter and Dart plugins installed.
- **Device/Emulator**: An Android or iOS device, or emulator/simulator for running the app.

## Getting Started & Local Setup
Follow these steps to get your development environment set up:

1. **Clone the repository** (or download the project source):
   ```bash
   git clone <repository-url>
   cd Daily-Attendance-App
   ```

2. **Install dependencies**:
   Fetch all necessary Flutter packages defined in `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   Connect a device or start an emulator, then run:
   ```bash
   flutter run
   ```

## Building for Production
To build a release version of the application:
- **Android APK**:
  ```bash
  flutter build apk --release
  ```
- **Android AppBundle**:
  ```bash
  flutter build appbundle --release
  ```
- **iOS**:
  ```bash
  flutter build ios --release
  ```
