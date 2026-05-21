# Expense Tracker

A comprehensive Flutter mobile application for tracking expenses, managing budgets, and gaining AI-powered financial insights.

## 📋 Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the App](#running-the-app)

## ✨ Features

- **Expense Management**: Track and categorize your daily expenses with ease
- **Budget Planning**: Set and monitor budgets for different expense categories
- **AI Insights**: Get intelligent financial insights powered by Google Generative AI
- **Multi-language Support**: Available in English and Arabic (AR)
- **Secure Authentication**: Google Sign-In and biometric authentication support
- **Real-time Notifications**: Stay updated with push notifications
- **Data Persistence**: Cloud storage with Firebase Firestore
- **Dark Mode Support**: Modern UI with theme customization
- **Search & Filter**: Easily find and filter your expenses

## 🛠️ Technology Stack

### Framework & Language
- **Flutter**: 3.11.4+
- **Dart**: Latest version

### State Management
- **flutter_bloc**: 9.1.1 - For robust state management

### Backend & Database
- **Firebase Core**: 4.8.0 - Backend infrastructure
- **Firebase Auth**: 6.5.0 - Authentication
- **Cloud Firestore**: 6.4.0 - Database
- **Firebase Messaging**: 16.2.1 - Push notifications

### Authentication
- **Google Sign-In**: 7.2.0 - OAuth authentication
- **Local Auth**: 3.0.1 - Biometric authentication

### UI & Visualization
- **Flutter Animate**: 4.5.2 - Smooth animations
- **FL Chart**: 1.2.0 - Data visualization
- **Flutter SVG**: 2.3.0 - SVG support
- **Flutter Floating Bottom Bar**: 2.0.0 - Custom navigation

### AI & Machine Learning
- **Google Generative AI**: 0.4.7 - AI-powered insights

### Utilities
- **GetIt**: 9.2.1 - Service locator
- **Shared Preferences**: 2.5.5 - Local storage
- **Equatable**: 2.0.8 - Equality comparison
- **Intl**: 0.20.2 - Internationalization
- **UUID**: 4.5.3 - Unique identifier generation

## 📂 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── app_guard.dart           # App guard/wrapper
├── core/
│   ├── di/                  # Dependency injection
│   ├── constants/           # Application constants
│   ├── service/             # Core services
│   └── theme/               # Theme configuration
├── components/              # Reusable UI components
├── features/
│   ├── auth/               # Authentication feature
│   ├── expenses/           # Expense management feature
│   ├── categories/         # Category management feature
│   ├── budget/             # Budget management feature
│   └── ai_insight/         # AI insights feature
├── l10n/                    # Localization files
└── utilities/               # Helper utilities
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.11.4 or higher
- **Dart SDK**: Latest version
- **Android Studio** or **Xcode** (for building)
- **Firebase Project**: Set up a Firebase project for authentication and database

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/eliasnadder/expense-tracker.git
   cd expense-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Configuration

1. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add your Android and iOS apps to the Firebase project
   - Download and place configuration files:
     - `google-services.json` for Android (`android/app/`)
     - `GoogleService-Info.plist` for iOS (`ios/Runner/`)

2. **Enable Services**
   - Firebase Authentication (Google Sign-In)
   - Cloud Firestore
   - Firebase Cloud Messaging

3. **Google AI Configuration**
   - Enable Google Generative AI API in your Firebase project
   - Configure API keys as needed

### Running the App

**Development**
```bash
flutter run
```

**Release Build**
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📱 App Features in Detail

### Expense Tracking
- Add, edit, and delete expenses
- Categorize expenses automatically
- View expense history and timeline
- Search and filter expenses by date, category, and amount

### Budget Management
- Set budget limits for different categories
- Track spending against budgets
- Receive alerts when approaching budget limits
- Visual progress indicators

### AI Insights
- Get personalized financial recommendations
- Analyze spending patterns
- Receive smart suggestions for cost optimization

### Authentication
- Secure Google Sign-In
- Biometric login (fingerprint/face recognition)
- Session management

## 🔒 Security

- Firebase Authentication for secure login
- Biometric authentication for app access
- Local encryption for sensitive data
- No sensitive credentials stored locally

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter BLoC Pattern](https://bloclibrary.dev/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Elias Nadder**

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support, email [support email] or create an issue in the GitHub repository.
