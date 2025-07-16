# Crux - Climbing Gym Route Management System

A comprehensive system for managing climbing gym routes with user interactions. Built with Flutter frontend and Python/Flask backend.

## Overview

**Crux** allows climbing gym users to:
- Browse and filter routes by grade and wall section
- Like their favorite routes
- Comment on routes and share beta
- Propose different grades for routes
- Report warnings about route conditions (broken holds, safety issues, etc.)
- Create new routes (for route setters)

## Architecture

- **Backend**: Python Flask REST API with SQLite database
- **Frontend**: Flutter mobile application
- **Communication**: HTTP REST API

## Quick Start

### Prerequisites

- Python 3.8+ 
- Flutter SDK
- Android Studio (for Android development)
- VS Code or your preferred IDE

### 1. Setup Backend

```bash
cd backend
setup.bat  # or manually create venv and install requirements
venv\Scripts\activate.bat
python app.py
```

The backend will run on `http://localhost:5000`

### 2. Setup Frontend

```bash
cd frontend
setup.bat  # or manually run flutter pub get
flutter run
```

## Project Structure

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
