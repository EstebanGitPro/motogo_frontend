# MotoGo Frontend

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.14.0-blue)](CHANGELOG.md)
[![SonarCloud](https://img.shields.io/badge/SonarCloud-Analyzed-F3702A?logo=sonarcloud)](https://sonarcloud.io/project/overview?id=EstebanGitPro_motogo_frontend)

> Mobile application for **MotoGo** — helping motorcyclists find trusted workshops, compare services tailored to their registered vehicles, and request quotes or diagnostics before visiting.

---

## 📖 Table of Contents

- [Vision](#-vision)
- [Key Features](#-key-features)
- [Technology Stack](#-technology-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Available Commands](#-available-commands)
- [Testing](#-testing)
- [Build & Release](#-build--release)
- [Contributing](#-contributing)
- [Credits](#-credits)
- [License](#-license)

---

## 🎯 Vision

For motorcyclists who don't have a reliable way to find trusted workshops offering technical services and consumables that match their needs, **MotoGo** is a mobile application that saves users both time and money when searching for motorcycle services.

Unlike Yelp, Google Maps, or Yellow Pages, MotoGo provides:

- ✅ Access to a **service catalog filtered by registered vehicles** in the user's profile
- ✅ **Nearby service information** with map-based discovery
- ✅ Ability to **request quotes or approximate diagnostics** before traveling to the location

---

## ✨ Key Features

| Module | Features |
|--------|----------|
| **Authentication** | Login, registration, password recovery, email verification |
| **User Profile** | Edit profile, change password, account deletion |
| **Motorcycles** | Registration, editing, profile images, evidence gallery, deletion |
| **Branch Discovery** | Map-based nearby search, branch detail view, schedule information |
| **Branch Management** | Register/edit branches, manage franchise, branch services, schedules |
| **Service Catalog** | Browse services filtered by vehicle, technical catalogs |
| **Diagnostics** | Request diagnostic, WhatsApp integration, permission handling |
| **Service History** | Completed services, motorcycle service history |
| **Ratings** | Service reviews and ratings |
| **Admin** | Admin dashboard, admin service management |

---

## 🛠 Technology Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.8.1 |
| **Language** | Dart 3.8.1 |
| **State Management** | [BLoC](https://bloclibrary.dev/) (flutter_bloc) |
| **Dependency Injection** | [Kiwi](https://pub.dev/packages/kiwi) + kiwi_generator |
| **HTTP Client** | [Dio](https://pub.dev/packages/dio) |
| **Authentication** | Firebase Auth |
| **File Storage** | Firebase Storage |
| **Maps** | Mapbox Maps Flutter |
| **Geolocation** | Geolocator + Permission Handler |
| **Secure Storage** | flutter_secure_storage |
| **Localization** | easy_localization |
| **Testing** | flutter_test, mockito, bloc_test |
| **Code Quality** | SonarCloud, flutter_lints, Husky pre-commit hooks |
| **Architecture** | Clean Architecture (3-layer) |

---

## 🏗 Architecture

MotoGo Frontend follows a **Feature-First Clean Architecture** pattern with 3 layers per feature:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│         (Pages, Widgets, BLoC / Cubit)              │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                      │
│       (Entities, Use Cases, Repository Contracts)    │
├─────────────────────────────────────────────────────┤
│                     Data Layer                       │
│      (Models, DataSources, Repository Impl)          │
└─────────────────────────────────────────────────────┘
```

**Key principles:**

- Each **feature** is self-contained with its own `data/`, `domain/`, and `presentation/` layers
- **BLoC** handles all state management with clear events and states
- **Kiwi** provides compile-time dependency injection
- Domain layer defines repository interfaces; Data layer implements them
- **Core** module provides shared utilities, widgets, networking, and constants

---

## 📁 Project Structure

```
motogo_frontend/
├── lib/
│   ├── main.dart                      # Application entrypoint
│   └── src/
│       ├── core/                      # Shared infrastructure
│       │   ├── catalogs/              # Shared catalog logic
│       │   ├── config/                # App configuration
│       │   ├── constants/             # Feature-based constants
│       │   ├── errors/                # Error handling & failures
│       │   ├── geocoding/             # Geocoding service
│       │   ├── injector/              # Kiwi DI setup
│       │   ├── mixins/                # Shared mixins
│       │   ├── models/                # Core models
│       │   ├── network/               # HTTP client, interceptors
│       │   ├── routes/                # App routing
│       │   ├── services/              # Shared services
│       │   ├── user/                  # User session management
│       │   ├── utils/                 # Utility functions
│       │   ├── validators/            # Input validators
│       │   └── widgets/               # Reusable widgets
│       └── features/                  # Feature modules (36 features)
│           ├── login/                 # Authentication
│           ├── register_person/       # User registration
│           ├── user_home/             # User home (map discovery)
│           ├── my_motorcycles/        # Motorcycle management
│           ├── my_branches/           # Branch listing
│           ├── register_branch/       # Branch registration
│           ├── diagnostic/            # Diagnostic flow
│           ├── service_ratings/       # Service reviews
│           ├── admin_home/            # Admin dashboard
│           └── ...                    # 27 more feature modules
├── test/                              # Unit & widget tests (mirror structure)
├── assets/
│   ├── lang/                          # i18n translation files
│   └── icons/                         # App icons
├── scripts/
│   ├── run_dev.sh                     # Run with env variables
│   ├── build_release.sh               # Build APK/AAB with secrets
│   └── emu-pixel.sh                   # Launch Pixel emulator
├── android/                           # Android platform config
├── ios/                               # iOS platform config
├── .env.example                       # Environment variable template
├── analysis_options.yaml              # Dart linter rules
├── pubspec.yaml                       # Dependencies
└── sonar-project.properties           # SonarCloud config
```

---

## 🚀 Getting Started

**Estimated time:** 10–15 minutes

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Flutter** | ≥ 3.8.1 | Framework |
| **Dart** | ≥ 3.8.1 | Language (bundled with Flutter) |
| **Android Studio** or **VS Code** | Latest | IDE with Flutter plugin |
| **Xcode** | Latest (macOS only) | iOS development |
| **Android Emulator** or physical device | — | Testing |

### Step 1: Clone the Repository

```bash
git clone https://github.com/EstebanGitPro/motogo_frontend.git
cd motogo_frontend
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Generate Code (Kiwi DI)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

| Variable | Purpose | Where to Get It |
|----------|---------|-----------------|
| `MAPBOX_ACCESS_TOKEN` | Map rendering & geocoding | [Mapbox Dashboard](https://account.mapbox.com/) |

### Step 5: Firebase Configuration

Ensure the Firebase configuration files are in place:

- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

> Download from [Firebase Console](https://console.firebase.google.com/) → Project Settings → Your Apps.

### Step 6: Install Husky Pre-commit Hooks

```bash
npm install
```

### Step 7: Run the Application

```bash
# Using the dev script (recommended — loads .env automatically)
./scripts/run_dev.sh

# Or manually
flutter run --dart-define=MAPBOX_ACCESS_TOKEN=your_token_here
```

### ✅ Verification

| Check | How to Verify |
|-------|---------------|
| App launches | Splash screen appears with MotoGo logo |
| Map loads | User home screen shows Mapbox map |
| Backend connected | Login screen can communicate with API |

> **Note:** The app requires the [MotoGo Backend](https://github.com/EstebanGitPro/motogo_backend_f) running for full functionality.

---

## 📋 Available Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run in debug mode |
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run tests with coverage report |
| `flutter analyze` | Run static analysis (linter) |
| `dart run build_runner build` | Generate code (Kiwi DI) |
| `dart run build_runner watch` | Watch mode for code generation |
| `./scripts/run_dev.sh` | Run with environment variables loaded |
| `./scripts/build_release.sh apk` | Build release APK |
| `./scripts/build_release.sh appbundle` | Build release AAB (Play Store) |
| `./scripts/emu-pixel.sh` | Launch Pixel emulator |

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Coverage Report

```bash
flutter test --coverage
# Output: coverage/lcov.info

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Testing Patterns

| Layer | Framework | Pattern |
|-------|-----------|---------|
| **BLoC** | `bloc_test` | Test events → states transitions |
| **Use Cases** | `mockito` | Mock repository, test business logic |
| **Repositories** | `mockito` | Mock data source, test data mapping |
| **Models** | `flutter_test` | Test JSON serialization, `copyWith`, equality |

---

## 📦 Build & Release

### Debug APK

```bash
flutter build apk --debug
```

### Release APK

```bash
./scripts/build_release.sh apk
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Play Store Bundle (AAB)

```bash
./scripts/build_release.sh appbundle
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our development workflow, coding standards, and pull request process.

---

## 🏆 Credits

See [CREDITS.md](CREDITS.md) for third-party attributions.

---

## 🛡️ Security

To report a vulnerability, please read our [Security Policy](SECURITY.md).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<p align="center">
  <sub>Built with ❤️ by the MotoGo team</sub>
</p>
