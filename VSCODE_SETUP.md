# VS Code Setup Guide

Welcome to the Kimeru Dictionary project! This guide will help you set up your development environment in Visual Studio Code.

## 📋 Prerequisites

Before setting up VS Code, ensure you have the following installed on your system:

1.  **Flutter SDK:** Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install) for your OS.
2.  **Dart SDK:** Usually bundled with Flutter.
3.  **Git:** Required for version control.

---

## 🛠️ VS Code Configuration

### 1. Recommended Extensions

Install the following extensions from the VS Code Marketplace for the best development experience:

- **Flutter** (`Dart-Code.flutter`) - Essential for Flutter development, debugging, and hot reload.
- **Dart** (`Dart-Code.dart-code`) - Language support for Dart.
- **SQLite Viewer** (`qwtel.sqlite-viewer`) - Helpful for inspecting the mobile app's local database.
- **Pubspec Assist** (`jeroen-meijer.pubspec-assist`) - Easily add and update dependencies in `pubspec.yaml`.
- **Error Lens** (`usernamehw.errorlens`) - Improves visibility of warnings and errors.

### 2. Opening the Project

For the best results, it is recommended to open the **root folder** of the repository in VS Code.

VS Code will automatically detect the `mobile` and `web` directories as separate Flutter projects.

---

## 🚀 Running the Apps

### Mobile App

1. Open the file `mobile/lib/main.dart`.
2. Ensure a mobile device or emulator is connected (check the bottom right of the VS Code window).
3. Press `F5` or go to **Run > Start Debugging**.

### Web Portal

1. Open the file `web/lib/main.dart`.
2. Connect "Chrome" or "Edge" as the target device.
3. Press `F5` or go to **Run > Start Debugging**.

---

## 🔑 Environment Secrets (Web Only)

The Web Portal requires a **GitHub Personal Access Token (PAT)** to interact with the dictionary data.

1. Generate a PAT on GitHub with `repo` scope.
2. When the Web App launches, you will need to log in via the Admin Login page using your GitHub credentials/token.
3. _Note: Local development used a Mock Service if the token is not provided._

---

## 🔍 Useful Commands

Run these in the integrated terminal:

- **Get Dependencies:** `flutter pub get` (Run inside `/mobile` or `/web`)
- **Fix Lint Issues:** `dart fix --apply`
- **Run Tests:** `flutter test`
