# Climbing Gym Flutter App

A Flutter mobile application for interacting with climbing gym routes.

## Features

- View all routes in the climbing gym
- Filter routes by wall section and grade
- Like/unlike routes
- Add comments to routes
- Propose different grades for routes
- Report warnings about route conditions
- Create new routes

## Setup

1. Make sure you have Flutter installed:
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Make sure the backend API is running at `http://localhost:5000`

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── route_models.dart     # Data models
├── providers/
│   └── route_provider.dart   # State management
├── services/
│   └── api_service.dart      # API communication
├── screens/
│   ├── home_screen.dart      # Main routes list
│   ├── route_detail_screen.dart  # Route details and interactions
│   └── add_route_screen.dart # Create new route
└── widgets/
    ├── route_card.dart       # Route display card
    ├── filter_bar.dart       # Filtering controls
    └── route_interactions.dart # Like, comment, etc.
```

## API Integration

The app communicates with the Flask backend at `http://localhost:5000/api`.

### Key Endpoints Used:
- `GET /api/routes` - Get all routes
- `GET /api/routes/{id}` - Get route details
- `POST /api/routes` - Create new route
- `POST /api/routes/{id}/like` - Like a route
- `POST /api/routes/{id}/comments` - Add comment
- `POST /api/routes/{id}/grade-proposals` - Propose grade
- `POST /api/routes/{id}/warnings` - Report warning

## User Features

### Route Browsing
- View all routes with basic information
- Filter by wall section and grade
- See route statistics (likes, comments, warnings)

### Route Details
- View full route information
- See all user interactions
- Access interaction buttons

### User Interactions
- Like/unlike routes
- Add comments
- Propose different grades with reasoning
- Report various types of warnings

### Route Management
- Create new routes with complete information
- Specify grade, wall section, color, and description
