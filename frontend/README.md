# Crux Frontend - Flutter Mobile App

A comprehensive Flutter mobile application for climbing gym route management, user authentication, and community interactions with Material Design 3 and advanced state management.

## Overview

The Crux frontend is a feature-rich Flutter application that provides climbers with an intuitive interface to browse routes, track progress, share feedback, and connect with the climbing community. Built with modern Flutter architecture patterns and Material Design 3.

## Features

### Authentication & User Management
- **Secure Authentication**: JWT-based login and registration with persistent sessions
- **User Profiles**: Comprehensive profile management with statistics and achievements
- **Session Management**: Automatic token validation and refresh handling

### Route Discovery & Management
- **Advanced Browsing**: Browse all climbing routes with detailed information
- **Smart Filtering**: Filter by wall section, grade, lane, route setter, and interaction status
- **Multi-Sort Options**: Sort by date, difficulty, popularity, and more
- **Route Creation**: Add new routes with complete details and validation
- **Search & Discovery**: Find routes that match your climbing style

### User Interactions
- **Likes System**: Express appreciation for routes with visual feedback
- **Comments**: Share detailed feedback, beta, and experiences
- **Grade Proposals**: Suggest alternative difficulty ratings with reasoning
- **Warnings & Reports**: Report safety issues, broken holds, or maintenance needs
- **Tick Tracking**: Record successful ascents with attempt counts and notes
- **Flash Recognition**: Special tracking for first-try completions

### Profile & Analytics
- **Performance Statistics**: Comprehensive climbing analytics and progress tracking
- **Grade Analysis**: Detailed statistics by difficulty level with success rates
- **Time-based Filtering**: View progress over different time periods
- **Achievement Tracking**: Monitor personal bests and climbing milestones
- **Visual Charts**: Interactive charts showing grade distribution and progress
- **History Views**: Complete history of ticks, likes, and interactions

### Advanced Features
- **3D Wall Visualization**: Interactive climbing wall topology viewer
- **Real-time Updates**: Live data synchronization with pull-to-refresh
- **Offline Support**: Graceful handling of network connectivity issues
- **Material Design 3**: Modern UI with dynamic theming and accessibility
- **Responsive Design**: Optimized for various screen sizes and orientations

## Quick Start

### Prerequisites
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: Included with Flutter
- **Development Tools**: VS Code, Android Studio, or IntelliJ IDEA
- **Backend API**: Crux backend running on `http://localhost:5000`

### Installation

1. **Verify Flutter Installation**:
   ```bash
   flutter doctor
   ```

2. **Install Dependencies**:
   ```bash
   cd frontend
   flutter pub get
   ```

3. **Run the Application**:
   ```bash
   flutter run
   ```

### Development Setup

#### For Android Development:
```bash
# Check Android setup
flutter doctor --android-licenses

# Run on Android device/emulator
flutter run -d android
```

#### For iOS Development (macOS only):
```bash
# Run on iOS simulator
flutter run -d ios
```

#### For Web Development:
```bash
# Run on web browser
flutter run -d chrome
```

## Project Architecture

### Directory Structure
```
frontend/
├── lib/
│   ├── main.dart                           # App entry point with auth wrapper
│   ├── models/                             # Data models and DTOs
│   │   ├── route_models.dart              # Route, Like, Comment, Warning, Tick
│   │   ├── user_models.dart               # User authentication models
│   │   ├── profile_models.dart            # User statistics and profile data
│   │   └── climbing_wall_models.dart      # 3D wall visualization models
│   ├── providers/                          # State management with Provider
│   │   ├── auth_provider.dart             # Authentication state
│   │   ├── route_provider.dart            # Route data and filtering logic
│   │   └── profile_provider.dart          # User profile and statistics
│   ├── services/                           # API communication layer
│   │   ├── api_service.dart               # Main REST API service
│   │   ├── auth_service.dart              # Authentication service
│   │   └── climbing_wall_service.dart     # 3D wall data service
│   ├── screens/                            # Full-screen views
│   │   ├── login_screen.dart              # Authentication UI
│   │   ├── main_navigation_screen.dart    # Bottom navigation wrapper
│   │   ├── home_screen.dart               # Routes listing with filters
│   │   ├── route_detail_screen.dart       # Detailed route view
│   │   ├── add_route_screen.dart          # Route creation form
│   │   └── profile_screen.dart            # User profile with tabs
│   └── widgets/                            # Reusable UI components
│       ├── route_card.dart                # Route display cards
│       ├── route_interactions.dart        # Interaction buttons (like, tick, etc.)
│       ├── filter_drawer.dart             # Advanced filtering interface
│       ├── interactive_climbing_wall.dart # 3D wall viewer
│       ├── performance_summary_card.dart  # Statistics summary cards
│       ├── grade_statistics_chart.dart    # Performance visualization
│       ├── ticks_list.dart                # User's completed routes list
│       └── likes_list.dart                # User's liked routes list
├── assets/
│   └── models/                             # 3D model files
│       ├── crux.json                      # Wall topology data
│       └── crux.png                       # Wall texture image
├── android/                                # Android-specific configuration
├── ios/                                    # iOS-specific configuration
├── web/                                    # Web-specific configuration
├── pubspec.yaml                           # Dependencies and app configuration
└── README.md                              # This file
```

### State Management Architecture

The app uses the **Provider** pattern for clean state management:

```dart
// Main provider hierarchy
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: AuthProvider()),
    ChangeNotifierProxyProvider<AuthProvider, RouteProvider>(),
    ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(),
  ],
  child: ClimbingGymApp(),
)
```

### Data Flow
1. **Authentication**: JWT tokens managed by `AuthProvider`
2. **API Communication**: Services handle HTTP requests with authentication
3. **State Updates**: Providers notify listeners of data changes
4. **UI Updates**: Widgets rebuild automatically with `Consumer` widgets

## Key Components

### Authentication System

#### Login/Registration Screen
```dart
class LoginScreen extends StatefulWidget {
  // Features:
  // - Toggle between login and registration
  // - Form validation with real-time feedback
  // - Secure password handling
  // - Loading states and error handling
  // - Modern gradient design
}
```

#### Auth Provider
```dart
class AuthProvider with ChangeNotifier {
  // Features:
  // - JWT token management
  // - Persistent session storage
  // - User registration and login
  // - Automatic token validation
  // - Session expiration handling
}
```

### Route Management

#### Home Screen
```dart
class HomeScreen extends StatefulWidget {
  // Features:
  // - Route listing with pagination
  // - Advanced filtering drawer
  // - Interactive climbing wall viewer
  // - Pull-to-refresh functionality
  // - Search and sort capabilities
}
```

#### Route Provider
```dart
class RouteProvider with ChangeNotifier {
  // Features:
  // - Route CRUD operations
  // - Multi-criteria filtering
  // - Client-side and server-side filtering
  // - Sorting options (date, grade, popularity)
  // - Interaction state management
}
```

### User Interactions

#### Route Interactions Widget
```dart
class RouteInteractions extends StatefulWidget {
  // Features:
  // - Like/unlike with visual feedback
  // - Tick recording with attempt tracking
  // - Comment addition with validation
  // - Grade proposal system
  // - Warning reporting interface
}
```

### Profile & Analytics

#### Profile Screen
```dart
class ProfileScreen extends StatefulWidget {
  // Features:
  // - Tab-based navigation (Performance, Ticks, Likes)
  // - Time-based filtering
  // - Comprehensive statistics display
  // - Interactive charts and graphs
  // - Achievement tracking
}
```

#### Performance Analytics
- **Grade Statistics**: Success rates by difficulty level
- **Time Analysis**: Progress tracking over different periods
- **Achievement Metrics**: Personal bests and milestones
- **Visual Charts**: Interactive grade distribution charts

## API Integration

### Base Configuration
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Features:
  // - Automatic JWT token inclusion
  // - Error handling and retry logic
  // - Request/response logging
  // - Network connectivity handling
}
```

### Endpoint Integration

#### Authentication Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication
- `GET /auth/me` - Current user information

#### Route Endpoints
- `GET /routes` - Route listing with filtering
- `GET /routes/{id}` - Detailed route information
- `POST /routes` - Route creation

#### Interaction Endpoints
- `POST /routes/{id}/like` - Like route
- `POST /routes/{id}/ticks` - Record ascent
- `POST /routes/{id}/comments` - Add comment
- `POST /routes/{id}/grade-proposals` - Propose grade
- `POST /routes/{id}/warnings` - Report issue

#### Profile Endpoints
- `GET /user/ticks` - User's completed routes
- `GET /user/likes` - User's liked routes
- `GET /user/stats` - Comprehensive statistics

## UI/UX Features

### Material Design 3
- **Dynamic Theming**: Adaptive color schemes
- **Modern Components**: Updated Material 3 widgets
- **Accessibility**: Screen reader support and high contrast
- **Typography**: Material 3 text styles and hierarchy

### Interactive Elements
- **Smooth Animations**: Page transitions and micro-interactions
- **Loading States**: Skeleton screens and progress indicators
- **Error Handling**: User-friendly error messages and retry options
- **Feedback Systems**: Snackbars, dialogs, and visual confirmations

### Responsive Design
- **Adaptive Layouts**: Optimized for phones and tablets
- **Safe Area Handling**: Proper handling of notches and system UI
- **Orientation Support**: Portrait and landscape orientations
- **Platform Adaptation**: Native look and feel on each platform

## Data Models

### Route Model
```dart
class Route {
  final int id;
  final String name;
  final String grade;              // "V0" through "V10+"
  final String routeSetter;
  final String wallSection;        // "Overhang Wall", "Slab Wall", etc.
  final int lane;
  final String? color;             // Hold color
  final String? description;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int gradeProposalsCount;
  final int warningsCount;
  final int ticksCount;
  
  // Detailed interaction data (when loaded)
  final List<Like>? likes;
  final List<Comment>? comments;
  final List<GradeProposal>? gradeProposals;
  final List<Warning>? warnings;
  final List<Tick>? ticks;
}
```

### User Models
```dart
class User {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final bool isActive;
}

class UserTick {
  final int id;
  final int routeId;
  final String routeName;
  final String routeGrade;
  final String wallSection;
  final int attempts;
  final bool flash;
  final String? notes;
  final DateTime createdAt;
}

class ProfileStats {
  final int totalTicks;
  final int totalLikes;
  final int totalComments;
  final int totalFlashes;
  final double averageAttempts;
  final String? hardestGrade;
  final int uniqueWallSections;
  final List<String> achievedGrades;
}
```

## Advanced Features

### 3D Wall Visualization
```dart
class InteractiveClimbingWall extends StatefulWidget {
  // Features:
  // - Interactive 3D climbing wall model
  // - Route highlighting and selection
  // - Touch-based navigation
  // - Real-time route data overlay
}
```

### Filtering System
```dart
enum FilterState { all, only, exclude }
enum SortOption { newest, oldest, easiest, hardest, mostLiked }

class FilterDrawer extends StatefulWidget {
  // Features:
  // - Multi-criteria filtering
  // - Wall section selection
  // - Grade range filtering
  // - Lane-specific filtering
  // - Route setter filtering
  // - Interaction-based filtering (ticked, liked, warned)
}
```

### Performance Analytics
```dart
class GradeStatisticsChart extends StatefulWidget {
  // Features:
  // - Interactive grade distribution charts
  // - Success rate visualization
  // - Time-based progress tracking
  // - Achievement milestone display
}
```

## Configuration

### Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                    # HTTP client for API calls
  provider: ^6.0.5               # State management
  shared_preferences: ^2.2.2     # Local data persistence
  jwt_decoder: ^2.0.1            # JWT token handling
  flutter_3d_controller: ^2.2.0  # 3D visualization
  flutter_inappwebview: ^6.0.0   # Web view support
  cupertino_icons: ^1.0.2        # iOS-style icons

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0          # Dart linting rules
```

### Asset Configuration
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/models/              # 3D model files
```

## Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/auth_test.dart
```

### Test Structure
```
test/
├── unit/                       # Unit tests for models and services
├── widget/                     # Widget tests for UI components
└── integration/                # Integration tests for full flows
```

## Performance Optimization

### Network Performance
- **Request Caching**: Smart caching of route data
- **Pagination**: Efficient loading of large datasets
- **Offline Support**: Graceful degradation without network

### UI Performance
- **Lazy Loading**: Routes loaded on demand
- **Image Optimization**: Efficient image loading and caching
- **State Management**: Minimal rebuilds with targeted listeners

### Memory Management
- **Resource Cleanup**: Proper disposal of controllers and subscriptions
- **Image Caching**: Efficient image memory management
- **Provider Cleanup**: Automatic cleanup of provider resources

## Build & Deployment

### Development Build
```bash
# Debug build for testing
flutter run --debug

# Profile build for performance testing
flutter run --profile
```

### Production Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS App Store
flutter build ios --release
```

### Web Deployment
```bash
# Build for web
flutter build web --release

# Serve locally
flutter run -d chrome
```

## Error Handling

### Network Errors
- **Connection Issues**: Graceful handling of network connectivity
- **Timeout Handling**: Automatic retry with exponential backoff
- **Authentication Errors**: Automatic token refresh and re-authentication

### User Experience
- **Loading States**: Clear indication of background operations
- **Error Messages**: User-friendly error descriptions
- **Retry Mechanisms**: Easy recovery from temporary failures

## Accessibility

### Screen Reader Support
- **Semantic Labels**: Proper labeling for all interactive elements
- **Reading Order**: Logical navigation flow
- **State Announcements**: Clear communication of state changes

### Visual Accessibility
- **High Contrast**: Support for high contrast themes
- **Text Scaling**: Proper handling of system text scaling
- **Color Independence**: Information not conveyed through color alone

## Localization Support

The app is designed for future localization:

```dart
// Localization setup (future enhancement)
class AppLocalizations {
  static const supportedLocales = [
    Locale('en', 'US'),  // English
    Locale('es', 'ES'),  // Spanish
    Locale('fr', 'FR'),  // French
  ];
}
```

## Development Guidelines

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused

### Widget Organization
- Separate business logic from UI code
- Use stateless widgets when possible
- Extract complex widgets into separate files
- Implement proper widget testing

### State Management Best Practices
- Use Provider for app-wide state
- Keep providers focused and single-purpose
- Implement proper error handling in providers
- Use ProxyProvider for dependent state

## Troubleshooting

### Common Issues

#### Build Issues
```bash
# Clean build cache
flutter clean
flutter pub get

# Update Flutter
flutter upgrade
```

#### Network Issues
- Ensure backend is running on `http://localhost:5000`
- Check network permissions in platform-specific configuration
- Verify API endpoints are accessible

#### Authentication Issues
- Clear app data to reset stored tokens
- Check JWT token expiration
- Verify API authentication headers

## Future Enhancements

### Planned Features
- **Social Features**: Follow other climbers, climb together
- **Photo Uploads**: Add photos to routes and comments
- **Offline Mode**: Full offline functionality with sync
- **Push Notifications**: Route updates and social interactions
- **Competition Mode**: Climbing competitions and leaderboards
- **Advanced Analytics**: Machine learning insights
- **Wearable Integration**: Smartwatch support

### Technical Improvements
- **GraphQL Migration**: More efficient data fetching
- **State Management**: Consider Riverpod or BLoC
- **Testing**: Increase test coverage to 90%+
- **Performance**: Advanced optimization and monitoring
- **Accessibility**: Enhanced accessibility features

## Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Follow the coding standards and add tests
4. Ensure all tests pass: `flutter test`
5. Submit a pull request with detailed description

### Code Review Guidelines
- Test on multiple devices and platforms
- Verify accessibility compliance
- Check performance impact
- Ensure proper error handling
- Update documentation as needed

## Support & Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Provider State Management](https://pub.dev/packages/provider)

### Getting Help
- Check existing GitHub issues
- Create detailed bug reports
- Include device information and logs
- Provide steps to reproduce issues

---

**Current Version**: 0.3.0  
**Flutter Version**: 3.0+  
**Supported Platforms**: Android, iOS, Web  
**Last Updated**: January 2025
