# Crux Backend - Flask REST API

A comprehensive Flask-based REST API for climbing gym route management with JWT authentication, user interactions, and comprehensive route tracking.

## Overview

The Crux backend provides a complete API for managing climbing gym routes, user authentication, and community interactions. Built with Flask and SQLAlchemy, it offers a robust foundation for climbing gym management systems.

## Features

### Core Functionality
- **JWT Authentication**: Secure user registration, login, and session management
- **Route Management**: Complete CRUD operations with detailed route information
- **French Grading System**: Uses the French rope climbing grade system (3a through 9c with + variants)
- **Database-Defined Colors**: Hold colors and grade colors are defined and managed in the database
- **User Interactions**: Comprehensive tracking of likes, comments, grade proposals, warnings, and advanced tick system with independent top rope/lead send tracking
- **Statistics & Analytics**: User performance tracking and climbing statistics
- **Data Filtering**: Advanced filtering and sorting capabilities
- **Sample Data**: Automatic initialization with realistic test data

### Security & Performance
- Password hashing with Flask-Bcrypt
- JWT token validation and expiration handling
- CORS support for cross-origin requests
- Comprehensive error handling and logging
- Request/response logging middleware

## Quick Start

### Prerequisites
- Python 3.8 or higher
- pip (Python package installer)

### Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd Crux/backend
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application**:
   ```bash
   python app.py
   ```

The API will be available at `http://localhost:5000` with automatic database initialization and sample data.

### Database Migration (For Existing Installations)

If you have an existing database and want to upgrade to the new tick system with independent top rope/lead tracking:

```bash
# Run the migration script
python migrate_db.py
```

This migration will:
- Add new columns for `top_rope_send`, `lead_send`, `top_rope_flash`, `lead_flash`, and `updated_at`
- Migrate existing tick data to the new format
- Preserve all existing user progress

### Environment Variables (Optional)
```bash
export JWT_SECRET_KEY="your-production-secret-key"
export FLASK_ENV="development"  # or "production"
```

## Database Models

### User Model
```python
class User:
    id: Integer (Primary Key)
    username: String (Unique, Required)
    email: String (Unique, Required)
    password_hash: String (Required)
    created_at: DateTime
    is_active: Boolean
```

### Route Model
```python
class Route:
    id: Integer (Primary Key)
    name: String (Required)
    grade: String (Required)           # French climbing grades: "3a", "5c", "6a+", "7b", etc.
    grade_color: String                # Color associated with the grade (auto-assigned)
    route_setter: String (Required)
    wall_section: String (Required)    # e.g., "Overhang Wall"
    lane: Integer (Required)
    color: String (Optional)           # Hold color from predefined list
    description: Text (Optional)
    created_at: DateTime
    
    # Relationships
    likes: List[Like]
    comments: List[Comment]
    grade_proposals: List[GradeProposal]
    warnings: List[Warning]
    ticks: List[Tick]
```

### Interaction Models
```python
class Like:
    id: Integer (Primary Key)
    user_id: Integer (Foreign Key)
    route_id: Integer (Foreign Key)
    created_at: DateTime

class Comment:
    id: Integer (Primary Key)
    user_id: Integer (Foreign Key)
    route_id: Integer (Foreign Key)
    content: Text (Required)
    created_at: DateTime

class GradeProposal:
    id: Integer (Primary Key)
    user_id: Integer (Foreign Key)
    route_id: Integer (Foreign Key)
    proposed_grade: String (Required)
    reasoning: Text (Optional)
    created_at: DateTime

class Warning:
    id: Integer (Primary Key)
    user_id: Integer (Foreign Key)
    route_id: Integer (Foreign Key)
    warning_type: String (Required)    # "broken_hold", "safety_issue", etc.
    description: Text (Required)
    status: String                     # "open", "acknowledged", "resolved"
    created_at: DateTime

class Tick:
    id: Integer (Primary Key)
    user_id: Integer (Foreign Key)
    route_id: Integer (Foreign Key)
    attempts: Integer                  # Total number of attempts
    top_rope_send: Boolean             # Successfully sent on top rope
    lead_send: Boolean                 # Successfully sent on lead
    top_rope_flash: Boolean            # Top rope flash (first try)
    lead_flash: Boolean                # Lead flash (first try)
    flash: Boolean                     # Legacy field (for backward compatibility)
    notes: Text (Optional)
    created_at: DateTime
    updated_at: DateTime
```

## API Endpoints

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
    "username": "string",
    "email": "string",
    "password": "string"
}

Response (201):
{
    "message": "User registered successfully",
    "access_token": "jwt_token",
    "user": {
        "id": 1,
        "username": "username",
        "email": "email@example.com",
        "created_at": "2025-01-01T00:00:00",
        "is_active": true
    }
}
```

#### Login User
```http
POST /api/auth/login
Content-Type: application/json

{
    "username": "string",
    "password": "string"
}

Response (200):
{
    "message": "Login successful",
    "access_token": "jwt_token",
    "user": { ... }
}
```

#### Get Current User
```http
GET /api/auth/me
Authorization: Bearer <jwt_token>

Response (200):
{
    "user": { ... }
}
```

### Route Endpoints

#### Get All Routes
```http
GET /api/routes
Authorization: Bearer <jwt_token>

# Optional query parameters:
# ?wall_section=Overhang Wall
# ?grade=V4
# ?lane=2

Response (200):
[
    {
        "id": 1,
        "name": "Crimpy Goodness",
        "grade": "V4",
        "route_setter": "Alice Johnson",
        "wall_section": "Overhang Wall",
        "lane": 1,
        "color": "Red",
        "description": "Technical crimps with a dynamic finish",
        "created_at": "2025-01-01T00:00:00",
        "likes_count": 5,
        "comments_count": 3,
        "grade_proposals_count": 1,
        "warnings_count": 0,
        "ticks_count": 8
    }
]
```

#### Get Specific Route
```http
GET /api/routes/{route_id}
Authorization: Bearer <jwt_token>

Response (200):
{
    "id": 1,
    "name": "Crimpy Goodness",
    # ... basic route info
    "likes": [...],           # Array of like objects
    "comments": [...],        # Array of comment objects
    "grade_proposals": [...], # Array of grade proposal objects
    "warnings": [...],        # Array of warning objects
    "ticks": [...]           # Array of tick objects
}
```

#### Create Route
```http
POST /api/routes
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "name": "New Route",
    "grade": "6a+",
    "route_setter": "John Doe",
    "wall_section": "Steep Wall",
    "lane": 3,
    "color": "Blue",
    "description": "Optional description"
}

Response (201):
{
    # ... created route object
}
```

### Route Interaction Endpoints

#### Like/Unlike Route
```http
POST /api/routes/{route_id}/like
Authorization: Bearer <jwt_token>

DELETE /api/routes/{route_id}/unlike
Authorization: Bearer <jwt_token>
```

#### Add Comment
```http
POST /api/routes/{route_id}/comments
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "content": "Great route! Really enjoyed the technical moves."
}
```

#### Propose Grade
```http
POST /api/routes/{route_id}/grade-proposals
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "proposed_grade": "6b",
    "reasoning": "Feels harder than 6a+ due to the dynamic move"
}
```

#### Report Warning
```http
POST /api/routes/{route_id}/warnings
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "warning_type": "broken_hold",
    "description": "The large red hold on move 3 is loose"
}
```

#### Track Progress & Sends
```http
# Add/Update tick record with attempts and sends
POST /api/routes/{route_id}/ticks
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "attempts": 3,                    # Total attempts (optional)
    "add_attempts": 2,                # Add attempts to existing count (optional)
    "top_rope_send": true,            # Mark top rope send (optional)
    "lead_send": false,               # Mark lead send (optional)
    "top_rope_flash": false,          # Mark top rope flash (optional)
    "lead_flash": false,              # Mark lead flash (optional)
    "notes": "Great route, tricky sequence"
}

# Add attempts only (without marking sends)
POST /api/routes/{route_id}/attempts
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "attempts": 2,                    # Number of attempts to add
    "notes": "Working on the crux move"
}

# Mark a specific send type
POST /api/routes/{route_id}/send
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
    "send_type": "top_rope",          # "top_rope" or "lead"
    "notes": "Finally got it!"
}

# Remove all progress
DELETE /api/routes/{route_id}/ticks
Authorization: Bearer <jwt_token>
```

#### Check User Progress Status
```http
GET /api/routes/{route_id}/ticks/me
Authorization: Bearer <jwt_token>

Response (200):
{
    "ticked": true,
    "tick": {
        "id": 1,
        "user_id": 2,
        "user_name": "alice_johnson",
        "route_id": 1,
        "attempts": 5,
        "top_rope_send": true,
        "lead_send": false,
        "top_rope_flash": false,
        "lead_flash": false,
        "flash": false,
        "has_any_send": true,
        "has_any_flash": false,
        "notes": "Great route! Took several attempts to get the sequence",
        "created_at": "2025-01-01T00:00:00",
        "updated_at": "2025-01-01T12:30:00"
    }
}
```

### Configuration Endpoints

#### Get Grade Definitions
```http
GET /api/grade-definitions

Response (200):
[
    {
        "grade": "3a",
        "color": "green"
    },
    {
        "grade": "5c", 
        "color": "yellow"
    },
    {
        "grade": "6a+",
        "color": "orange"
    }
    // ... all French climbing grades with their colors
]
```

#### Get Hold Colors
```http
GET /api/hold-colors

Response (200):
[
    "Red", "Blue", "Green", "Yellow", "Orange", "Purple", 
    "Pink", "Black", "White", "Cyan", "Teal", "Lime", 
    "Indigo", "Brown", "Amber", "DeepOrange", "LightBlue", "LightGreen"
]
```

#### Get Grade Colors
```http
GET /api/grade-colors

Response (200):
{
    "3a": "green",
    "3b": "green", 
    "3c": "green",
    "4a": "green",
    "4b": "green",
    "4c": "green",
    "5a": "yellow",
    "5b": "yellow",
    "5c": "yellow",
    "6a": "orange",
    "6a+": "orange",
    "6b": "orange",
    "6b+": "orange",
    "6c": "orange",
    "6c+": "orange",
    "7a": "red",
    "7a+": "red",
    "7b": "red",
    "7b+": "red",
    "7c": "red",
    "7c+": "red",
    "8a": "purple",
    "8a+": "purple",
    "8b": "purple",
    "8b+": "purple",
    "8c": "purple",
    "8c+": "purple",
    "9a": "purple",
    "9a+": "purple",
    "9b": "purple",
    "9b+": "purple",
    "9c": "purple"
}
```

### User Profile Endpoints

#### Get User's Ticks
```http
GET /api/user/ticks
Authorization: Bearer <jwt_token>

Response (200):
[
    {
        "id": 1,
        "route_id": 1,
        "route_name": "Crimpy Goodness",
        "route_grade": "V4",
        "wall_section": "Overhang Wall",
        "attempts": 3,
        "flash": false,
        "notes": "...",
        "created_at": "2025-01-01T00:00:00"
    }
]
```

#### Get User's Likes
```http
GET /api/user/likes
Authorization: Bearer <jwt_token>
# Similar format to ticks
```

#### Get User Statistics
```http
GET /api/user/stats
Authorization: Bearer <jwt_token>

Response (200):
{
    "total_ticks": 15,
    "total_likes": 8,
    "total_comments": 12,
    "total_attempts": 45,
    "average_attempts": 3.0,
    
    "total_sends": 12,
    "top_rope_sends": 10,
    "lead_sends": 4,
    
    "total_flashes": 3,
    "top_rope_flashes": 2,
    "lead_flashes": 1,
    "legacy_flashes": 3,
    
    "hardest_grade": "6c",
    "hardest_top_rope_grade": "6c",
    "hardest_lead_grade": "6a+",
    "achieved_grades": ["5a", "5b", "5c", "6a", "6a+", "6b", "6b+", "6c"],
    "unique_wall_sections": 4
}
```

### Utility Endpoints

#### Get Wall Sections
```http
GET /api/wall-sections
Authorization: Bearer <jwt_token>

Response (200):
["Overhang Wall", "Slab Wall", "Steep Wall", "Vertical Wall"]
```

#### Get Available Grades
```http
GET /api/grades
Authorization: Bearer <jwt_token>

Response (200):
["V0", "V1", "V2", "V3", "V4", "V5", "V6", "V7"]
```

#### Get Lane Numbers
```http
GET /api/lanes
Authorization: Bearer <jwt_token>

Response (200):
[1, 2, 3, 4, 5, 6]
```

## Error Handling

The API returns consistent error responses:

```json
{
    "error": "Error message description",
    "details": "Additional error details (optional)"
}
```

Common HTTP status codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (invalid/missing token)
- `404`: Not Found
- `422`: Unprocessable Entity (invalid token format)
- `500`: Internal Server Error

## Sample Data

The application automatically initializes with sample data:

### Sample Users
- **admin** / **admin123** (Administrator)
- **alice_johnson** / **password123**
- **bob_smith** / **password123**
- **charlie_brown** / **password123**

### Sample Routes
1. **Crimpy Goodness** (V4) - Overhang Wall, Lane 1, Red
2. **Slab Master** (V2) - Slab Wall, Lane 3, Blue
3. **Power House** (V6) - Steep Wall, Lane 2, Yellow
4. **Finger Torture** (V5) - Overhang Wall, Lane 4, Green
5. **Beginner's Delight** (V1) - Vertical Wall, Lane 1, Orange
6. **The Gaston** (V3) - Vertical Wall, Lane 2, Purple

## Configuration

### Database Configuration
- **Development**: SQLite database (`climbing_gym.db`)
- **Production**: Configure `SQLALCHEMY_DATABASE_URI` environment variable

### JWT Configuration
- **Secret Key**: Set `JWT_SECRET_KEY` environment variable
- **Token Expiration**: 24 hours (configurable)
- **Algorithm**: HS256

### CORS Configuration
- **Allowed Origins**: `http://localhost:3000`, `http://127.0.0.1:3000`
- **Allowed Methods**: GET, POST, PUT, DELETE, OPTIONS
- **Allowed Headers**: Content-Type, Authorization

## Development Features

### Logging
- Request/response logging with authorization header masking
- Debug level logging in development mode
- Error tracking and monitoring

### Database Management
- Automatic table creation on first run
- Sample data initialization for testing
- SQLAlchemy ORM with relationship management

### Security Features
- Password hashing with Bcrypt
- JWT token validation with expiration
- CORS protection
- Input validation and sanitization

## Testing

Test the API using the sample authentication:

```bash
# Register or login to get token
curl -X POST http://localhost:5000/api/auth/login 
  -H "Content-Type: application/json" 
  -d '{"username": "admin", "password": "admin123"}'

# Use token for authenticated requests
curl -X GET http://localhost:5000/api/routes 
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Performance Considerations

- Database queries optimized with proper indexing
- Relationship loading optimized to prevent N+1 queries
- JSON responses include only necessary data
- Pagination recommended for large datasets (future enhancement)

## Deployment

### Development
```bash
python app.py
```

### Production
```bash
export FLASK_ENV=production
export JWT_SECRET_KEY=your-secure-secret-key
gunicorn app:app
```

## Future Enhancements

- Database migration system with Alembic
- Advanced filtering with complex queries
- File upload support for route photos
- Email notifications for warnings
- Admin dashboard endpoints
- Rate limiting and API quotas
- Database connection pooling
- Caching layer (Redis)
- API versioning
- OpenAPI/Swagger documentation

## Contributing

1. Follow PEP 8 style guidelines
2. Add type hints for new functions
3. Include docstrings for all public methods
4. Test all endpoints with various scenarios
5. Update this README for any API changes

## Dependencies

- **Flask 2.3.3**: Web framework
- **Flask-SQLAlchemy 3.0.5**: Database ORM
- **Flask-JWT-Extended 4.5.3**: JWT authentication
- **Flask-Bcrypt 1.0.1**: Password hashing
- **Flask-CORS 4.0.0**: Cross-origin support
- **python-dotenv 1.0.0**: Environment variable management
- **Werkzeug 2.3.7**: WSGI utilities

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

**Current Version**: 0.3.0  
**API Base URL**: `http://localhost:5000/api`  
**Last Updated**: January 2025
