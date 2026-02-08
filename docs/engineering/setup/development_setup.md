# Development Setup Guide - BeatRecall

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## 1. Prerequisites

### 1.1 Required Software
- **Flutter SDK:** Version 3.0 or higher
  - Download from: https://flutter.dev/docs/get-started/install
- **Dart:** Included with Flutter SDK
- **IDE:** One of the following:
  - Android Studio (recommended for Android development)
  - Visual Studio Code with Flutter extension
  - IntelliJ IDEA
- **Git:** For version control

### 1.2 Platform-Specific Requirements

#### For Android Development:
- Android Studio
- Android SDK (API Level 23 or higher)
- Android Emulator or physical device
- Java Development Kit (JDK) 11 or higher

#### For iOS Development (macOS only):
- Xcode 13 or higher
- CocoaPods
- iOS Simulator or physical device
- Apple Developer Account (for device testing)

---

## 2. Environment Setup

### 2.1 Install Flutter

#### Windows:
```bash
# Download Flutter SDK from flutter.dev
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS/Linux:
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

### 2.2 Verify Installation
```bash
# Check Flutter installation
flutter doctor -v

# Accept Android licenses (if needed)
flutter doctor --android-licenses

# Check for issues
flutter doctor
```

### 2.3 IDE Setup

#### VS Code:
1. Install Flutter extension
2. Install Dart extension
3. Restart VS Code
4. Run: `Flutter: Doctor` from command palette

#### Android Studio:
1. Install Flutter plugin
2. Install Dart plugin
3. Configure Flutter SDK path
4. Restart Android Studio

---

## 3. Project Setup

### 3.1 Clone Repository
```bash
git clone https://github.com/quablarox/BeatRecall.git
cd BeatRecall
```

### 3.2 Install Dependencies
```bash
# Get all packages
flutter pub get

# Verify dependencies
flutter pub outdated
```

### 3.3 Configure Development Environment

#### Create `.env` file (if needed for API keys):
```
YOUTUBE_API_KEY=your_api_key_here
```

#### Update `pubspec.yaml` if needed:
```yaml
dependencies:
  flutter:
    sdk: flutter
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  youtube_player_flutter: ^8.1.2
  provider: ^6.0.5  # or riverpod: ^2.3.0
  # Add other dependencies as needed
```

---

## 4. Running the Application

### 4.1 Check Available Devices
```bash
flutter devices
```

### 4.2 Run on Emulator/Simulator
```bash
# Start Android Emulator (from Android Studio)
# Or start iOS Simulator:
open -a Simulator

# Run app
flutter run
```

### 4.3 Run on Physical Device

#### Android:
1. Enable Developer Mode on device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

#### iOS:
1. Connect device via USB
2. Trust computer on device
3. Open Xcode and sign app
4. Run: `flutter run`

### 4.4 Development Mode Features
```bash
# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
# Open DevTools: Press 'd' in terminal
# Quit: Press 'q' in terminal
```

---

## 5. Project Structure

```
BeatRecall/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/                     # Core utilities
│   │   ├── constants/
│   │   ├── utils/
│   │   └── config/
│   ├── data/                     # Data layer
│   │   ├── models/              # Data models (Flashcard)
│   │   ├── repositories/        # Data access
│   │   └── data_sources/        # Local/Remote data sources
│   ├── domain/                   # Business logic layer
│   │   ├── entities/            # Domain entities
│   │   ├── repositories/        # Repository interfaces
│   │   └── use_cases/           # Business use cases
│   ├── services/                 # Service layer
│   │   ├── srs_service.dart     # SRS algorithm logic
│   │   ├── youtube_service.dart # YouTube integration
│   │   └── database_service.dart # Isar database
│   └── presentation/             # UI layer
│       ├── screens/             # App screens
│       │   ├── dashboard/
│       │   ├── quiz/
│       │   ├── library/
│       │   └── settings/
│       ├── widgets/             # Reusable widgets
│       └── providers/           # State management
├── test/                         # Unit tests
├── integration_test/             # Integration tests
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code
├── requirements/                 # Project requirements
├── pubspec.yaml                  # Dependencies
└── README.md                     # Project overview
```

---

## 6. Database Setup (Isar)

### 6.1 Generate Isar Schema
```bash
# Install Isar generator
flutter pub add isar_generator --dev
flutter pub add build_runner --dev

# Generate schema files
flutter pub run build_runner build
```

### 6.2 Database Initialization
```dart
// In lib/services/database_service.dart
import 'package:isar/isar.dart';

Future<void> initDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [FlashcardSchema],
    directory: dir.path,
  );
}
```

---

## 7. YouTube Integration

### 7.1 Get YouTube API Key (Optional for metadata)
1. Go to: https://console.cloud.google.com/
2. Create new project
3. Enable YouTube Data API v3
4. Create credentials (API Key)
5. Add to `.env` file

### 7.2 Configure YouTube Player
```yaml
# pubspec.yaml
dependencies:
  youtube_player_flutter: ^8.1.2
```

---

## 8. Development Workflow

### 8.1 Branch Strategy
```bash
# Create feature branch
git checkout -b feature/srs-implementation

# Make changes
# ...

# Commit changes
git add .
git commit -m "feat: implement SM-2 algorithm"

# Push to remote
git push origin feature/srs-implementation

# Create Pull Request on GitHub
```

### 8.2 Coding Standards
- Follow Dart style guide: https://dart.dev/guides/language/effective-dart
- Use `flutter analyze` before committing
- Format code: `dart format .`
- Write tests for new features
- Document public APIs

### 8.3 Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/srs_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 9. Building for Release

### 9.1 Android APK
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/
```

### 9.2 iOS App
```bash
# Build for iOS
flutter build ios --release

# Open in Xcode for signing and distribution
open ios/Runner.xcworkspace
```

---

## 10. Common Issues and Solutions

### 10.1 Flutter Doctor Issues
**Problem:** Android licenses not accepted
```bash
flutter doctor --android-licenses
```

**Problem:** Xcode not found
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### 10.2 Build Issues
**Problem:** Dependency conflicts
```bash
flutter pub upgrade --major-versions
flutter clean
flutter pub get
```

**Problem:** Gradle build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### 10.3 Emulator Issues
**Problem:** Emulator won't start
- Check BIOS virtualization enabled
- Try creating new virtual device
- Update Android Emulator in SDK Manager

---

## 11. Useful Commands

```bash
# Update Flutter
flutter upgrade

# Clear build cache
flutter clean

# Analyze code
flutter analyze

# Format code
dart format .

# Pub commands
flutter pub get          # Install dependencies
flutter pub upgrade      # Update dependencies
flutter pub outdated     # Check for updates

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# DevTools
flutter pub global activate devtools
devtools
```

---

## 12. Resources

### Documentation:
- Flutter: https://flutter.dev/docs
- Dart: https://dart.dev/guides
