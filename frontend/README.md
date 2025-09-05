# Crux Frontend - Flutter Mobile App

Flutter mobile app for climbing gym route management with Material Design 3.

## Quick Start

```bash
flutter pub get
flutter run
```
Connects to backend at `http://localhost:5000`

## Features

### Core Functionality
- **Route Discovery**: Browse, filter, and search climbing routes
- **User Authentication**: JWT-based login with nickname system
- **Tick Tracking**: Log attempts, sends (top rope/lead), and flashes
- **Social Features**: Like, comment, grade proposals, and warnings
- **Performance Analytics**: Statistics, charts, and grade progression
- **Localization**: English and French language support

### UI/UX
- **Material Design 3**: Modern theming with dynamic colors
- **Responsive Design**: Adapts to different screen sizes
- **Interactive Elements**: Smooth animations and feedback
- **3D Wall Viewer**: Interactive climbing wall visualization

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── providers/             # State management (Provider)
├── screens/               # Full-screen views
├── services/              # API communication
├── widgets/               # Reusable components
├── l10n/                 # Localization files
└── utils/                # Helper utilities
```

## Key Screens

- **Login**: Authentication with registration
- **Home**: Route listing with advanced filtering
- **Route Detail**: Full route information and interactions
- **Profile**: User statistics and climbing history
- **Add Route**: Route creation form

## State Management

Uses Provider pattern for clean state management:
- `AuthProvider` - Authentication and user session
- `RouteProvider` - Route data and filtering
- `ProfileProvider` - User statistics and history

## Localization

Supports English and French with:
- 350+ translation keys
- Date/time formatting
- Number formatting
- Pluralization support

## Dependencies

- Flutter 3.0+ - Mobile framework
- Provider 6.0.5 - State management
- HTTP 1.1.0 - API communication
- SharedPreferences 2.2.2 - Local storage
- JWT Decoder 2.0.1 - Token handling

## Sample Users

Login with: `admin/admin123` or `alice_johnson/password123`

### Route Discovery & Management
- **Advanced Browsing**: Browse all climbing routes with detailed information
- **French Grading System**: Full support for French rope climbing grades (3a through 9c with + variants)
- **Dynamic Color System**: Grade and hold colors loaded from backend database with hex precision for consistent display
- **Color Utilities**: Centralized color parsing and fallback handling through `ColorUtils` class
- **Smart Filtering**: Filter by wall section, grade, lane, route setter, and interaction status
- **Multi-Sort Options**: Sort by date, difficulty, popularity, and more
- **Route Creation**: Add new routes with complete details and validation
- **Search & Discovery**: Find routes that match your climbing style

### User Interactions
- **Likes System**: Express appreciation for routes with visual feedback
- **Comments**: Share detailed feedback, beta, and experiences
- **Grade Proposals**: Suggest alternative difficulty ratings with reasoning
- **Warnings & Reports**: Report safety issues, broken holds, or maintenance needs
- **Advanced Tick Tracking**: Comprehensive progress tracking system
  - **Independent Send Types**: Track top rope and lead sends separately
  - **Attempt Logging**: Record attempts without marking sends
  - **Flash Recognition**: Automatic detection and tracking of first-try completions
  - **Progress Management**: View and update climbing progress over time
  - **Style-Specific Statistics**: Separate statistics for top rope vs lead climbing

### Profile & Analytics
- **Comprehensive Performance Statistics**: Advanced climbing analytics with detailed progress tracking
  - **Send Type Breakdown**: Separate statistics for top rope vs lead climbing
  - **Flash Rate Analysis**: Track and analyze flash percentages by climbing style
  - **Attempt Tracking**: Monitor average attempts per send for different styles
  - **Grade Progression**: Visualize climbing progression across different grades
- **Enhanced Grade Analysis**: Detailed statistics by difficulty level with style-specific success rates
- **Time-based Filtering**: View progress over different time periods (all-time, monthly, weekly)
- **Achievement Tracking**: Monitor personal bests including hardest sends by style
- **Visual Charts**: Interactive charts showing grade distribution and climbing style progress
- **Detailed History Views**: Complete history of ticks with send type information, likes, and interactions

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
  // - French grading system support (3a-9c)
  // - Dynamic grade and hold color loading from backend
  // - Multi-criteria filtering
  // - Client-side and server-side filtering
  // - Sorting options (date, grade, popularity)
  // - Interaction state management
  // - Grade color mapping for UI consistency
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
- `POST /auth/register` - User registration (requires nickname)
- `POST /auth/login` - User authentication
- `GET /auth/me` - Current user information
- `PUT /user/nickname` - Update current user's nickname

#### Route Endpoints
- `GET /routes` - Route listing with filtering
- `GET /routes/{id}` - Detailed route information
- `POST /routes` - Route creation

#### Configuration Endpoints
- `GET /grade-definitions` - French climbing grades with color mappings and hex codes
- `GET /hold-colors` - Available hold colors with hex codes for precise color rendering
- `GET /grade-colors` - Grade-to-color mapping for consistent UI display
- `GET /wall-sections` - Available wall sections
- `GET /lanes` - Available lane numbers

### Color System Integration
```dart
class ColorUtils {
  /// Parse hex color string into Flutter Color object
  static Color parseHexColor(String? hexColor);
  
  /// Get grade color from backend data with fallback
  static Color getGradeColor(String grade, Map<String, String>? gradeColors);
  
  /// Get hold color with hex code preference
  static Color getHoldColor(String? colorName, String? colorHex);
}
```

Features:
- **Backend Integration**: All colors fetched from database with hex precision
- **Fallback Handling**: Graceful degradation to default colors if backend unavailable
- **Centralized Utilities**: Single source of truth for color parsing throughout the app
- **Consistent Display**: Ensures identical color representation across all UI components

#### Enhanced Tick Endpoints
- `POST /routes/{id}/ticks` - Record or update comprehensive tick data
- `POST /routes/{id}/attempts` - Add attempts without marking sends
- `POST /routes/{id}/send` - Mark specific send type (top_rope or lead)
- `GET /routes/{id}/ticks/me` - Get current user's tick status
- `DELETE /routes/{id}/ticks` - Remove tick data

#### Profile Endpoints
- `GET /user/ticks` - User's completed routes with send type details
- `GET /user/stats` - Comprehensive climbing statistics including:
  - Total sends by type (top rope, lead)
  - Flash rates by climbing style
  - Hardest grades achieved per style
  - Average attempts per send
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
  final String username; // private login
  final String nickname; // public display name shown in UI
  final String email;
  final DateTime createdAt;
  final bool isActive;
}
```

## UI Details
- Login/Registration: Registration form requires Nickname (3-20 chars, letters/numbers/underscore). Username is for login only.
- Profile and Header: UI shows `currentUser.nickname` and uses the first letter of nickname for avatar initials.
- Interactions: Lists of likes/comments/ticks show `user_name` from the backend, which represents the user’s nickname.

---

**Current Version**: 0.3.1  
**Flutter Version**: 3.0+  
**Supported Platforms**: Android, iOS, Web  
**Last Updated**: August 2025
