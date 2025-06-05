# Bellume Flutter

A facial analysis and improvement app built with Flutter, featuring 3D face capture and personalized improvement recommendations.

## Features

### Core Functionality
- **3-Photo Facial Analysis**: Front view and side profile capture
- **AI-Powered Measurements**: Bizygomatic width, intercanthal distance, facial thirds ratio, etc.
- **Personalized Recommendations**: Custom improvement tips based on analysis
- **Progress Tracking**: Historical data and improvement monitoring
- **AI Coach**: Interactive chat for guidance and tips based on your scan results

### Auth & Security
- Secure user authentication with Supabase
- Email verification and password strength validation
- Protected routes and user session management

## Architecture

### 🏗️ Project Structure
```
lib/
├── core/
│   └── theme/           # Design system (colors, typography, spacing)
├── data/
│   ├── models/          # Data models and entities
│   └── services/        # API services and data sources
└── presentation/
    ├── providers/       # Riverpod state management
    ├── routes/          # GoRouter navigation
    ├── screens/         # UI screens
    └── widgets/         # Reusable UI components
```

### Tech Stack
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod 2.4+
- **Navigation**: GoRouter 12.1+
- **Backend**: Supabase
- **Local Storage**: Hive
- **Camera**: Camera plugin with ML integration
- **UI/UX**: Material Design 3, Lottie animations

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS development setup (for iOS builds)

## Support
For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Bellume Flutter** - Transforming facial analysis with cutting-edge technology 🚀 
