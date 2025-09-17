# Crux Climbing Gym - Frontend

A Flutter mobile application for managing climbing gym routes, user interactions, and climbing analytics. The app provides an interactive 3D visualization of climbing routes and comprehensive user management features.

## 🏗️ Architecture Overview

### Design Pattern
The application follows **Clean Architecture** principles with the **Provider pattern** for state management:

```
├── Presentation Layer (Screens & Widgets)
├── Business Logic Layer (Providers)
├── Data Layer (Services & Models)
└── External Layer (API, Cache, Storage)
```

### Key Architectural Decisions
- **State Management**: Provider pattern with ChangeNotifier
- **Dependency Injection**: Provider's dependency injection container
- **Caching Strategy**: Intelligent caching with TTL and cache invalidation
- **Platform Strategy**: Web-first with cross-platform support
- **Authentication**: WordPress cookie-based authentication with JS interop

## 📱 Core Features

### Route Management
- **Interactive 3D Climbing Wall**: Visual route representation using `flutter_3d_controller`
- **Advanced Filtering**: Multi-criteria filtering (grade, setter, wall section, color)
- **Route Interactions**: Likes, comments, ticks, projects, grade proposals
- **Real-time Updates**: Cached API with intelligent refresh strategies

### User Management & Authentication
- **WordPress Integration**: Cookie-based authentication via JavaScript interop
- **Role-Based Access**: Admin, route setter, and member permissions
- **User Profiles**: Personal statistics, climbing progress, achievements
- **Multi-language Support**: English and French localization

### Performance Features
- **Intelligent Caching**: Multi-layer caching with configurable TTL
- **Offline Capability**: Local data persistence using SharedPreferences
- **Optimistic Updates**: Immediate UI feedback with background synchronization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥3.0.0
- Dart SDK ≥3.0.0
- VS Code with Flutter extension or Android Studio

### Installation & Setup
```bash
# Clone and navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Generate localization files
flutter pub run intl_utils:generate

# Run the application
flutter run
```

### Platform-Specific Setup

#### Web Development
```bash
# Run on Chrome for development
flutter run -d chrome

# Build for web deployment
flutter build web
```

#### Mobile Development
```bash
# Android
flutter run -d android
flutter build apk --release

# iOS (macOS only)
flutter run -d ios
flutter build ios --release

```

## 🏛️ Project Structure

```
lib/
├── main.dart                    # Application entry point
├── generated/                   # Auto-generated localization files
│   └── l10n/
├── l10n/                       # Translation files (.arb format)
│   ├── app_en.arb              # English translations
│   └── app_fr.arb              # French translations
├── models/                     # Data models and DTOs
│   ├── climbing_wall_models.dart
│   ├── lane_models.dart
│   ├── profile_models.dart
│   ├── role_models.dart
│   ├── route_models.dart
│   └── user_models.dart
├── providers/                  # State management (Business Logic)
│   ├── auth_provider.dart      # Authentication state
│   ├── locale_provider.dart    # Language/locale management
│   ├── profile_provider.dart   # User profile data
│   ├── role_provider.dart      # Role-based permissions
│   ├── route_provider.dart     # Route data and filtering
│   └── theme_provider.dart     # Theme configuration
├── screens/                    # UI Screens (Presentation)
│   ├── main_navigation_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── route_detail_screen.dart
│   ├── add_route_screen.dart
│   ├── role_management_screen.dart
│   └── user_management_screen.dart
├── services/                   # Data layer services
│   ├── auth_service.dart       # Authentication logic
│   ├── cached_api_service.dart # HTTP client with caching
│   ├── cache_service.dart      # Cache management
│   ├── climbing_wall_service.dart
│   ├── js_auth_service.dart    # JavaScript interop for auth
│   └── role_service.dart
├── utils/                      # Utility functions
├── widgets/                    # Reusable UI Components
│   ├── custom_app_bar.dart
│   ├── interactive_climbing_wall.dart
│   ├── route_card.dart
│   ├── filter_bar.dart
│   ├── grade_chip.dart
│   ├── performance_summary_card.dart
│   └── ...
└── assets/
    ├── logo/                   # App branding assets
    └── models/                 # 3D model files
        ├── crux.json          # 3D climbing wall model
        └── crux.png           # Texture assets
```

## 🔧 Technical Stack

### Core Dependencies
```yaml
# Framework & Language
flutter: ^3.0.0
dart: ^3.0.0

# State Management
provider: ^6.0.5

# HTTP & Networking
http: ^1.1.0

# UI & Visualization
flutter_3d_controller: ^2.2.0
flutter_inappwebview: ^6.0.0

# Localization
flutter_localizations: (SDK)
intl: ^0.19.0

# Storage & Persistence
shared_preferences: ^2.2.2

# Platform Support
web: 1.1.1
```

### Development Tools
```yaml
# Linting & Code Quality
flutter_lints: ^2.0.0

# Localization Generation
intl_utils: ^2.8.7

# Build Tools
build_runner: ^2.4.7

```

## 🏗️ State Management Architecture

### Provider Hierarchy
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<LocaleProvider>(),
    ChangeNotifierProvider<ThemeProvider>(),
    ChangeNotifierProvider<AuthProvider>(),
    ChangeNotifierProxyProvider<AuthProvider, RouteProvider>(),
    ChangeNotifierProxyProvider<AuthProvider, RoleProvider>(),
    ChangeNotifierProxyProvider2<AuthProvider, RouteProvider, ProfileProvider>(),
  ],
)
```

### Key Providers

#### AuthProvider
- Manages authentication state and user sessions
- Integrates with WordPress authentication via cookies
- Handles automatic session validation and refresh

#### RouteProvider
- Manages climbing route data and filtering logic
- Implements intelligent caching with background refresh
- Handles route interactions (likes, comments, ticks)

#### ProfileProvider
- Manages user profile data and statistics
- Tracks climbing progress and achievements
- Handles personal route history

## 🌐 API Integration

### Architecture Pattern
The app uses a **hybrid API strategy**:
- **Web Platform**: Direct WordPress REST API calls via JavaScript interop
- **Mobile Platforms**: Python backend proxy for authentication handling

### Caching Strategy
```dart
class CachedApiService {
  // Multi-layer caching with configurable TTL
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  
  // Intelligent cache invalidation
  void invalidateCache(String pattern);
  
  // Background refresh capabilities
  Future<void> backgroundRefresh();
}
```

### Authentication Flow
1. **Web**: WordPress cookie authentication via JS interop
2. **Mobile**: Token-based authentication through Python backend
3. **Session Management**: Automatic token refresh and validation
4. **Security**: Role-based access control (RBAC)

## 🌍 Internationalization

### Supported Languages
- English (en) - Primary language
- French (fr) - Secondary language

### Adding New Translations
1. Add keys to `lib/l10n/app_en.arb`
2. Add translations to `lib/l10n/app_fr.arb`
3. Run `flutter pub run intl_utils:generate`
4. Import generated classes: `import 'generated/l10n/app_localizations.dart';`

### Usage in Code
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.routesTitle); // Automatically uses user's locale
```

## 🎨 UI/UX Architecture

### Theme System
- **Material Design 3**: Modern Material You design system
- **Dynamic Theming**: User-configurable themes via ThemeProvider
- **Responsive Design**: Adaptive layouts for different screen sizes

### Widget Organization
- **Atomic Design**: Organized from atoms to organisms
- **Reusable Components**: Highly composable widget architecture
- **Custom Widgets**: Specialized climbing-focused components

### Key UI Components
- `InteractiveClimbingWall`: 3D visualization of climbing routes
- `RouteCard`: Comprehensive route information display
- `FilterBar`: Advanced filtering interface
- `PerformanceSummaryCard`: User statistics visualization

## 🔧 Development Workflow

### Code Organization
```bash
# Feature-based organization
lib/
├── feature/
│   ├── models/
│   ├── providers/
│   ├── services/
│   ├── screens/
│   └── widgets/
```

### Testing Strategy
```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart

# Widget tests
flutter test test/widget_test.dart
```

### Code Quality
```bash
# Lint code
flutter analyze

# Format code
flutter format .

# Generate documentation
dartdoc
```

## 🚀 Build & Deployment

### Web Deployment
```bash
# Build optimized web version
flutter build web --release

# Deploy to web server
# Output: build/web/
```

### Mobile App Distribution
```bash
# Android Play Store
flutter build appbundle --release

# iOS App Store
flutter build ios --release
```

### Environment Configuration
```yaml
# Production build
flutter build [platform] --release --dart-define=ENV=production

# Development build
flutter build [platform] --debug --dart-define=ENV=development
```

## 🔒 Security & Performance

### Security Measures
- **Authentication**: Secure WordPress integration
- **Authorization**: Role-based access control
- **Data Validation**: Client and server-side validation
- **Secure Storage**: Encrypted local storage for sensitive data

### Performance Optimizations
- **Lazy Loading**: On-demand data loading
- **Image Optimization**: Cached and compressed images
- **Memory Management**: Efficient widget lifecycle management
- **Network Optimization**: Request batching and caching

## 📚 Additional Resources

### Documentation
- [Custom AppBar Documentation](docs/CUSTOM_APPBAR.md)
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package Documentation](https://pub.dev/packages/provider)

### Development Tools
- **Flutter Inspector**: Widget tree debugging
- **Dart DevTools**: Performance profiling
- **Flutter Performance**: Performance monitoring

---

**Version**: 0.11.1  
**Platform**: Flutter 3.0+  
**Architecture**: Clean Architecture with Provider Pattern
