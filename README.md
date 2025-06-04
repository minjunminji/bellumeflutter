# Bellume Flutter

A comprehensive facial analysis and improvement app built with Flutter, featuring 3D face capture, AI-powered measurements, and personalized improvement recommendations.

## Features

### 🎯 Core Functionality
- **3-Photo Facial Analysis**: Front view and left/right profile capture
- **AI-Powered Measurements**: Bizygomatic width, intercanthal distance, facial thirds ratio
- **Personalized Recommendations**: Custom improvement tips based on analysis
- **Progress Tracking**: Historical data and improvement monitoring
- **AI Coach**: Interactive chat for guidance and tips

### 🔐 Authentication & Security
- Secure user authentication with Supabase
- Email verification and password strength validation
- Protected routes and user session management

### 📱 User Experience
- Modern Material Design 3 UI
- Responsive design for all screen sizes
- Smooth animations and transitions
- Intuitive navigation with bottom tabs
- Dark/light theme support ready

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

### 🛠️ Tech Stack
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod 2.4+
- **Navigation**: GoRouter 12.1+
- **Backend**: Supabase (Authentication & Database)
- **Local Storage**: Hive (Offline data)
- **Camera**: Camera plugin with ML integration
- **UI/UX**: Material Design 3, Lottie animations

### 📐 Design System
- **Colors**: Teal primary with semantic color palette
- **Typography**: Hierarchical text styles with proper contrast
- **Spacing**: Consistent 8px grid system
- **Components**: Reusable cards, buttons, and form elements

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS development setup (for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bellume_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Supabase**
   - Create a Supabase project
   - Update `lib/data/services/supabase_service.dart` with your credentials
   - Set up database tables (see Database Schema below)

5. **Run the app**
   ```bash
   flutter run
   ```

### Database Schema

Create these tables in your Supabase project:

```sql
-- Profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- Facial metrics table
CREATE TABLE facial_metrics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  bizygomatic_width DECIMAL,
  intercanthal_distance DECIMAL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Measurements table
CREATE TABLE measurements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  name TEXT NOT NULL,
  value DECIMAL NOT NULL,
  ideal_value DECIMAL NOT NULL,
  unit TEXT NOT NULL,
  percentile INTEGER,
  category TEXT,
  description TEXT,
  tips TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Development

### Code Generation
Run this command when you modify Hive models:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### State Management
The app uses Riverpod for state management with these key providers:
- `authStateProvider`: Authentication state
- `currentUserProvider`: Current user information
- `supabaseServiceProvider`: Supabase service instance

### Navigation
GoRouter handles all navigation with:
- Protected routes requiring authentication
- Nested navigation for main app tabs
- Modal scan flow for photo capture

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Deployment

### Android
1. Configure signing in `android/app/build.gradle`
2. Build release APK: `flutter build apk --release`
3. Build App Bundle: `flutter build appbundle --release`

### iOS
1. Configure signing in Xcode
2. Build for iOS: `flutter build ios --release`
3. Archive and upload via Xcode

## Features Roadmap

### Phase 1 (Current)
- ✅ Authentication system
- ✅ Basic UI/UX framework
- ✅ Navigation structure
- ✅ Data models and services

### Phase 2 (Next)
- 📷 Camera integration
- 🤖 ML model integration
- 📊 Results visualization
- 💾 Data persistence

### Phase 3 (Future)
- 🎯 Advanced measurements
- 📈 Progress tracking
- 🤖 AI coach improvements
- 🔔 Push notifications

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent file structure

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Bellume Flutter** - Transforming facial analysis with cutting-edge technology 🚀 