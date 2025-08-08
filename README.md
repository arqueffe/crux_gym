# Crux - Climbing Gym Route Management System

Welcome to Crux, a comprehensive climbing gym management system that allows climbers to track routes, share feedback, and build community around their climbing adventures.

## Overview

Crux is a full-stack application consisting of:
- **Backend**: Flask-based REST API with SQLite database and JWT authentication
- **Frontend**: Flutter mobile application with Material Design and comprehensive user features

The system helps climbing gym members:
- Browse available routes with detailed information and advanced filtering
- Track their climbing progress with advanced tick system supporting:
  - Independent top rope and lead send tracking
  - Attempt logging without marking sends
  - Automatic flash detection and tracking
  - Style-specific statistics and personal bests
- Manage personal climbing projects with goal-oriented route tracking
- Share feedback through likes, comments, grade proposals, and warnings
- Report route issues and maintenance needs
- View personal climbing profiles with performance analytics
- Experience interactive climbing wall topology visualization
- Enjoy color-coded grading system with backend-driven visual consistency

## Quick Start

### Prerequisites
- Python 3.8+ (for backend)
- Flutter 3.0+ (for frontend)
- Git

### Backend Setup
```bash
cd backend
python -m pip install -r requirements.txt
python app.py
```
The backend will start on `http://localhost:5000` with sample data automatically initialized.

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```
The app will connect to the backend API automatically.

## Project Structure

```
Crux/
├── backend/                          # Flask REST API
│   ├── app.py                       # Main Flask application with full API
│   ├── requirements.txt             # Python dependencies
│   ├── climbing_gym.db             # SQLite database (auto-generated)
│   └── README.md                   # Backend documentation
├── frontend/                        # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart               # App entry point with auth wrapper
│   │   ├── models/                 # Data models (Route, User, Profile)
│   │   │   ├── route_models.dart   # Route, Like, Comment, Warning, Tick models
│   │   │   ├── user_models.dart    # User authentication models
│   │   │   ├── profile_models.dart # User statistics and profile models
│   │   │   └── climbing_wall_models.dart # 3D wall visualization models
│   │   ├── providers/              # State management
│   │   │   ├── auth_provider.dart  # Authentication state
│   │   │   ├── route_provider.dart # Route data and filtering
│   │   │   └── profile_provider.dart # User profile and statistics
│   │   ├── services/               # API communication
│   │   │   ├── api_service.dart    # Main API service
│   │   │   ├── auth_service.dart   # Authentication service
│   │   │   └── climbing_wall_service.dart # 3D wall service
│   │   ├── screens/                # App screens
│   │   │   ├── login_screen.dart   # Authentication UI
│   │   │   ├── main_navigation_screen.dart # Bottom navigation
│   │   │   ├── home_screen.dart    # Routes listing with filters
│   │   │   ├── route_detail_screen.dart # Detailed route view
│   │   │   ├── add_route_screen.dart # Route creation
│   │   │   └── profile_screen.dart # User profile with statistics
│   │   └── widgets/                # Reusable UI components
│   │       ├── route_card.dart     # Route display cards
│   │       ├── route_interactions.dart # Like, comment, tick buttons
│   │       ├── filter_drawer.dart  # Advanced filtering UI
│   │       ├── interactive_climbing_wall.dart # 3D wall viewer
│   │       ├── performance_summary_card.dart # Statistics cards
│   │       ├── grade_statistics_chart.dart # Performance charts
│   │       ├── ticks_list.dart     # User's completed routes
│   │       └── likes_list.dart     # User's liked routes
│   ├── pubspec.yaml               # Flutter dependencies
│   ├── assets/models/             # 3D model assets
│   └── README.md                  # Frontend documentation
├── commit.sh                      # Version management script
├── VERSION.md                     # Current version (0.3.0)
└── README.md                     # This file
```

## Features

### Authentication & User Management
- Secure JWT-based authentication
- User registration and login
- Persistent session management
- User profile management

### Route Management
- Complete CRUD operations for climbing routes
- Detailed route information (grade, setter, wall section, lane, color)
- Route filtering by multiple criteria (wall section, grade, lane, setter)
- Advanced sorting options (newest, oldest, difficulty, popularity)
- Route search and discovery

### User Interactions
- **Likes**: Express appreciation for routes
- **Comments**: Share detailed feedback and beta
- **Grade Proposals**: Suggest alternative difficulty ratings with reasoning
- **Warnings**: Report safety issues, broken holds, or maintenance needs
- **Ticks**: Track successful ascents with attempt counts and notes
- **Flash Tracking**: Record first-try completions

### Profile & Statistics
- Comprehensive climbing statistics
- Performance analytics by grade and time period
- Personal achievement tracking
- Tick history with detailed information
- Grade progression tracking
- Wall section diversity metrics
- Average attempts and flash rate calculation

### Advanced Features
- Interactive 3D climbing wall visualization
- Real-time data synchronization
- Offline-capable design
- Responsive Material Design UI
- Advanced error handling and loading states
- Pull-to-refresh functionality

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user info

### Routes
- `GET /api/routes` - Get all routes (with filtering: wall_section, grade, lane)
- `GET /api/routes/{id}` - Get specific route with all interactions
- `POST /api/routes` - Create new route

### Route Interactions
- `POST /api/routes/{id}/like` - Like a route
- `DELETE /api/routes/{id}/unlike` - Unlike a route
- `POST /api/routes/{id}/comments` - Add comment
- `POST /api/routes/{id}/grade-proposals` - Propose grade change
- `POST /api/routes/{id}/warnings` - Report warning/issue
- `POST /api/routes/{id}/ticks` - Record successful ascent
- `DELETE /api/routes/{id}/ticks` - Remove tick
- `GET /api/routes/{id}/ticks/me` - Check if user has ticked route

### User Profile
- `GET /api/user/ticks` - Get user's completed routes
- `GET /api/user/likes` - Get user's liked routes  
- `GET /api/user/stats` - Get comprehensive user statistics

### Utility Endpoints
- `GET /api/wall-sections` - Get all unique wall sections
- `GET /api/grades` - Get all grades used in gym
- `GET /api/lanes` - Get all lane numbers

## Database Schema

### Core Models
- **User**: Authentication and profile information
- **Route**: Complete route details with metadata
- **Like**: User appreciation for routes
- **Comment**: Detailed user feedback
- **GradeProposal**: Alternative difficulty suggestions
- **Warning**: Safety and maintenance reports
- **Tick**: Successful ascent records

### Key Relationships
- Users can have multiple likes, comments, proposals, warnings, and ticks
- Routes contain aggregated counts for all interaction types
- Unique constraints prevent duplicate ticks per user-route combination

## Sample Data

The system initializes with sample data for immediate testing:

**Users:**
- `admin` / `admin123` (Administrator)
- `alice_johnson` / `password123`
- `bob_smith` / `password123`
- `charlie_brown` / `password123`

**Sample Routes:**
- "Crimpy Goodness" (V4) - Technical crimps with dynamic finish
- "Slab Master" (V2) - Balance and footwork focused
- "Power House" (V6) - Raw power moves with big holds
- "Finger Torture" (V5) - Tiny crimps and pinches
- "Beginner's Delight" (V1) - Perfect for new climbers
- "The Gaston" (V3) - Lots of gaston moves

## Technologies Used

### Backend
- **Flask**: Python web framework with RESTful API design
- **SQLAlchemy**: Object-relational mapping with SQLite
- **Flask-JWT-Extended**: Secure JWT authentication
- **Flask-Bcrypt**: Password hashing and security
- **Flask-CORS**: Cross-origin resource sharing

### Frontend
- **Flutter**: Cross-platform mobile app framework
- **Provider**: State management and dependency injection
- **Material Design 3**: Modern UI components and theming
- **HTTP**: RESTful API communication
- **SharedPreferences**: Local data persistence
- **JWT Decoder**: Token validation and management
- **Flutter 3D Controller**: Interactive 3D visualizations

## Development Features

### Version Management
- Automated versioning with `commit.sh` script
- Semantic versioning (major.minor.patch)
- Synchronized version updates across components

### Code Quality
- Comprehensive error handling throughout the stack
- Loading states and user feedback
- Responsive design patterns
- Clean architecture with separation of concerns

### Color System
- **Backend-Driven Colors**: All grade and hold colors are managed in the backend database
- **Hex Color Support**: Colors are stored as hex codes for precise color matching
- **Centralized Color Utilities**: Shared `ColorUtils` class for consistent color parsing
- **Fallback Mechanism**: Graceful degradation to default colors if backend data is unavailable
- **Visual Consistency**: Uniform color representation across all UI components

## Future Enhancements

- Route setting scheduling and management
- Social features (following other climbers, competitions)
- Photo uploads for routes
- Advanced analytics and reporting
- Push notifications for new routes
- Offline mode with data synchronization
- Admin dashboard for gym management

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the existing code style
4. Test thoroughly on both backend and frontend
5. Use the version management script: `./commit.sh "Your commit message" patch`
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or feature requests:
- Open a GitHub issue with detailed information
- Check existing documentation in backend/ and frontend/ README files
- Contact the development team

---

**Current Version**: 0.3.0  
**Last Updated**: January 2025## Project Structure

```
Crux/
├── backend/                 # Flask API
│   ├── app.py              # Main Flask application
│   ├── requirements.txt    # Python dependencies
│   ├── setup.bat          # Setup script
│   └── README.md          # Backend documentation
├── frontend/               # Flutter app
│   ├── lib/               # Dart source code
│   ├── pubspec.yaml       # Flutter dependencies
│   ├── setup.bat          # Setup script
│   └── README.md          # Frontend documentation
└── README.md              # This file
```

## Features

### Backend Features
- Route CRUD operations
- User interaction tracking (likes, comments, grade proposals, warnings)
- Gym topology management (wall sections)
- RESTful API design
- Sample data initialization

### Frontend Features
- Modern Material Design UI
- Real-time data updates
- Filtering and search capabilities
- User-friendly interaction forms
- Responsive design
- Error handling and loading states

## API Endpoints

### Routes
- `GET /api/routes` - Get all routes (with optional filtering)
- `GET /api/routes/{id}` - Get specific route with details
- `POST /api/routes` - Create new route

### User Interactions
- `POST /api/routes/{id}/like` - Like a route
- `DELETE /api/routes/{id}/unlike` - Unlike a route
- `POST /api/routes/{id}/comments` - Add comment
- `POST /api/routes/{id}/grade-proposals` - Propose grade change
- `POST /api/routes/{id}/warnings` - Report warning

### Utility
- `GET /api/wall-sections` - Get all wall sections
- `GET /api/grades` - Get all grades used

## Data Models

### Route
- Basic information: name, grade, route setter, wall section
- Optional: color, description
- Statistics: likes count, comments count, warnings count

### User Interactions
- **Likes**: Simple user appreciation
- **Comments**: Text feedback and beta sharing
- **Grade Proposals**: Suggest different difficulty with reasoning
- **Warnings**: Report issues (broken holds, safety concerns, etc.)

## Development

### Adding New Features

1. **Backend**: Add new endpoints in `app.py`, update models if needed
2. **Frontend**: Add new screens/widgets, update API service and provider

### Database Schema

The SQLite database includes:
- `route` - Route information
- `like` - User likes
- `comment` - User comments
- `grade_proposal` - Grade change suggestions
- `warning` - Route condition warnings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request
