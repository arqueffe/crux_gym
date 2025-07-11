# Climbing Gym Backend API

A Flask-based REST API for managing climbing gym routes and user interactions.

## Features

- Route management (CRUD operations)
- User interactions: likes, comments, grade proposals, warnings
- Gym topology with wall sections
- Route filtering by grade and wall section

## Setup

1. Run the setup script:
   ```bash
   setup.bat
   ```

2. Activate the virtual environment:
   ```bash
   venv\Scripts\activate.bat
   ```

3. Start the server:
   ```bash
   python app.py
   ```

The API will be available at `http://localhost:5000`

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

## Database

Uses SQLite with the following models:
- Route
- Like
- Comment
- GradeProposal
- Warning
