# Crux Climbing Gym Management System

A comprehensive climbing gym management platform featuring a Flutter mobile application and WordPress-based backend for route tracking, user interactions, and performance analytics.

## 🏗️ System Overview

- **Frontend**: Flutter mobile app with route visualization and cross-platform support
- **Backend**: WordPress plugin with REST API for gym management and user authentication
- **Architecture**: Clean Architecture with Provider pattern (Frontend) + WordPress REST API (Backend)

## ✨ Key Features

### 🧗‍♂️ Route Management
- Interactive climbing wall visualization
- Advanced filtering (grade, setter, wall section, color)
- Route interactions (likes, comments, ticks, projects)
- Grade proposals and safety warnings

### 👤 User Management
- WordPress cookie-based authentication
- Role-based access control (Admin, Route Setter, Member)
- Personal climbing statistics and progress tracking
- Multi-language support (English/French)

### 📊 Analytics & Performance
- Comprehensive climbing statistics
- Performance tracking (sends, attempts, flashes)
- Intelligent caching with offline capability
- Real-time updates and background sync

## 🚀 Quick Start

### Backend Setup (WordPress)
```bash
# Install WordPress and copy plugin
cp -r backend/wp-content/plugins/crux-climbing-gym /path/to/wordpress/htdocs/crux-climbing-gym/wp-content/plugins/

# Activate plugin in WordPress admin
# Plugin automatically creates database schema and sample data
```

### Frontend Setup (Flutter)
```bash
cd frontend

# Install dependencies
flutter pub get

# Generate localization files
flutter pub run intl_utils:generate

# Build the web application
flutter build web --base-href "/crux-climbing-gym/flutter-app/"

# Run the application
cp -r build/web /path/to/wordpress/htdocs/crux-climbing-gym/flutter-app
```

## 📁 Project Structure

```
topo_app/
├── backend/                    # WordPress backend
│   ├── wp-content/plugins/     # Main plugin directory
│   │   └── crux-climbing-gym/  # Plugin files and admin interface
│   └── requirements.txt        # Dependencies
├── frontend/                   # Flutter mobile app
│   ├── lib/                    # Application source code
│   │   ├── models/            # Data models
│   │   ├── providers/         # State management
│   │   ├── screens/           # UI screens
│   │   ├── services/          # API and data services
│   │   └── widgets/           # Reusable UI components
│   └── assets/                # Static assets and 3D models
└── README.md                  # This file
```

## 🛠️ Technology Stack

### Frontend
- **Flutter 3.0+** - Cross-platform mobile framework
- **Provider** - State management
- **flutter_3d_controller** - 3D visualization
- **HTTP** - API communication with intelligent caching

### Backend
- **WordPress 5.0+** - Content management system
- **PHP 7.4+** - Server-side logic
- **MySQL/MariaDB** - Database
- **WordPress REST API** - Backend API endpoints

## 📚 API Overview

Base URL: `/wp-json/crux/v1/`

### Core Endpoints
- `GET /routes` - Retrieve climbing routes with filtering
- `POST /routes/{id}/ticks` - Mark route completion
- `GET /user/stats` - Get user climbing statistics
- `GET /auth/me` - Current user authentication status

## 🔒 Authentication & Roles

- **Authentication**: WordPress cookie-based system
- **Admin**: Full system management access
- **Route Setter**: Route creation and editing
- **Member**: Route interaction and personal tracking

## 🌍 Internationalization

- English (primary)
- French (secondary)
- Extensible localization system

## 📱 Platform Support

- **Web**: Primary deployment target
- **Android**: Mobile app via Flutter
- **iOS**: Mobile app via Flutter (macOS required for development)

## 🔧 Development

### Prerequisites
- Flutter SDK ≥3.0.0
- WordPress 5.0+
- PHP 7.4+ with MySQL/MariaDB

### Documentation
- [Frontend Documentation](frontend/README.md) - Detailed Flutter app architecture
- [Backend Documentation](backend/README.md) - WordPress plugin implementation

## 📄 License

See [LICENSE](LICENSE) file for details.

---

**Version**: 0.11.1  
**Architecture**: Flutter + WordPress  
**Platform**: Cross-platform mobile with web backend