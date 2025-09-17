# Crux Climbing Gym Backend

A comprehensive WordPress-based backend system for managing climbing gym operations, including route tracking, user interactions, and performance analytics.

## Architecture Overview

The backend is built as a **WordPress plugin** (`crux-climbing-gym`) that provides:

- **REST API endpoints** for mobile/web frontend communication
- **Admin interface** for gym management
- **Database schema** for climbing gym data
- **User authentication** via WordPress cookie system
- **Role-based access control** (Admin, Route Setter, Member)

### Key Components

```
backend/
├── wp-content/plugins/crux-climbing-gym/    # Main WordPress plugin
│   ├── crux-climbing-gym.php               # Plugin entry point
│   ├── includes/                           # Core classes
│   │   ├── class-crux.php                 # Main plugin class
│   │   ├── class-crux-api.php             # REST API endpoints
│   │   ├── class-crux-activator.php       # Database setup
│   │   └── models/                        # Data models
│   │       ├── class-crux-route.php       # Route model
│   │       ├── class-crux-user.php        # User model
│   │       ├── class-crux-grade.php       # Grade model
│   │       └── class-crux-hold-colors.php # Hold colors model
│   ├── admin/                             # Admin interface
│   │   ├── class-crux-admin.php           # Admin controller
│   │   └── partials/                      # Admin page templates
│   └── public/                            # Public-facing functionality
├── requirements.txt                        # Python dependencies (legacy)
├── uploads.ini                            # PHP upload configuration
└── .gitignore                             # Git ignore rules
```

## Database Schema

The plugin creates 13 database tables with `crux_` prefix:

### Core Tables
- **`crux_routes`** - Climbing routes with grade, setter, wall section, lane
- **`crux_grades`** - French climbing grades (3a-9c) with difficulty values and colors
- **`crux_lanes`** - Lane numbers for route positioning
- **`crux_hold_colors`** - Available hold colors for routes

### User Interaction Tables
- **`crux_ticks`** - User completions (attempts, sends, flashes for top-rope and lead)
- **`crux_likes`** - Route likes from users
- **`crux_comments`** - Route comments
- **`crux_projects`** - Routes users are working on
- **`crux_warnings`** - Safety warnings for routes
- **`crux_grade_proposals`** - User-suggested grade changes

### User Management Tables
- **`crux_roles`** - Role definitions with capabilities
- **`crux_user_roles`** - User-role assignments
- **`crux_user_nicknames`** - Custom user nicknames

## REST API Endpoints

Base URL: `/wp-json/crux/v1/`

### Authentication
- `GET /auth/me` - Get current user information
- `GET /auth/permissions` - Get user permissions

### Routes
- `GET /routes` - Get all routes (with filtering by wall_section, grade, lane)
- `GET /routes/{id}` - Get route details with comments, warnings, grade proposals
- `POST /routes` - Create new route (route setter/admin only)

### Route Interactions
- `POST /routes/{id}/like` - Like a route
- `DELETE /routes/{id}/unlike` - Unlike a route
- `POST /routes/{id}/ticks` - Tick a route (mark as completed)
- `DELETE /routes/{id}/ticks` - Remove tick
- `POST /routes/{id}/attempts` - Add attempts without completing
- `POST /routes/{id}/send` - Mark specific send type (top_rope, lead, flash, lead_flash)
- `POST /routes/{id}/unsend` - Remove specific send type
- `POST /routes/{id}/comments` - Add comment
- `POST /routes/{id}/grade-proposals` - Propose grade change
- `POST /routes/{id}/projects` - Add to projects
- `DELETE /routes/{id}/projects` - Remove from projects
- `POST /routes/{id}/warnings` - Report safety warning

### User Data
- `GET /user/ticks` - User's completed routes
- `GET /user/likes` - User's liked routes  
- `GET /user/projects` - User's project routes
- `GET /user/stats` - Comprehensive climbing statistics
- `GET /user/nickname` - Get user's display nickname
- `PUT /user/nickname` - Update user's display nickname

### Reference Data
- `GET /grades` - Available French climbing grades
- `GET /grade-definitions` - Full grade definitions with colors
- `GET /grade-colors` - Grade-to-color mapping
- `GET /wall-sections` - Available wall sections
- `GET /lanes` - Available lanes
- `GET /hold-colors` - Available hold colors

## User Statistics

The API provides comprehensive climbing statistics including:

- **Totals**: ticks, sends, attempts, likes, comments, projects
- **Send Types**: top-rope sends/flashes, lead sends/flashes
- **Performance**: average attempts per send, favorite grade, hardest grade
- **Averages**: calculated average grade climbed

## Setup Instructions

### Prerequisites
- WordPress 5.0+ installation
- PHP 7.4+ with MySQL/MariaDB
- Web server (Apache/Nginx)

### Installation

1. **Install WordPress**
   ```bash
   # Follow standard WordPress installation
   # Configure wp-config.php with database settings
   ```

2. **Install Plugin**
   ```bash
   # Copy plugin to WordPress plugins directory
   cp -r wp-content/plugins/crux-climbing-gym /path/to/wordpress/wp-content/plugins/
   ```

3. **Activate Plugin**
   - Log into WordPress admin
   - Go to Plugins → Installed Plugins
   - Activate "Crux Climbing Gym Management"

4. **Configure Upload Settings** (if needed)
   ```bash
   # Copy upload configuration
   cp uploads.ini /path/to/php/conf.d/
   # Or add to php.ini:
   # file_uploads = On
   # memory_limit = 256M
   # upload_max_filesize = 64M
   # post_max_size = 64M
   # max_execution_time = 300
   ```

### Database Setup

The plugin automatically creates all necessary tables on activation with sample data:

- **34 French climbing grades** (1 to 9c) with colors
- **10 hold colors** (Red, Blue, Green, Yellow, Orange, Purple, Pink, Black, White, Gray)
- **20 lanes** (numbered 1-20)
- **3 user roles** (Admin, Route Setter, Member)

## Admin Interface

Access via WordPress admin: **Climbing Gym** menu

### Pages Available:
- **Routes** - View and manage all climbing routes
- **Add Route** - Create new climbing routes
- **Climbers** - Manage users and view climbing statistics  
- **Statistics** - Overall gym analytics and popular routes
- **Settings** - Plugin configuration

## User Roles & Permissions

### Admin (Role ID: 1)
- Full access to all features
- User management, route creation/editing/deletion
- View analytics and manage warnings

### Route Setter (Role ID: 2)  
- Create and edit own routes
- All member capabilities

### Member (Role ID: 3)
- View routes, like/comment/tick routes
- Track personal progress and projects
- Propose grade changes and report warnings

## Authentication

Uses **WordPress cookie-based authentication**:

- Supports standard WordPress logged-in cookies
- Custom header support: `X-WordPress-Cookie` or `Authorization: WordPress <cookie>`
- Automatic role assignment (defaults to Member if no role set)
- Session validation against WordPress user sessions

## Configuration

### WordPress Settings
Standard WordPress configuration in `wp-config.php`

### Plugin Settings  
Available via admin interface:
- Gym name
- Public registration settings
- Routes per page display

### PHP Configuration
Recommended `uploads.ini` settings for file uploads:
```ini
file_uploads = On
memory_limit = 256M  
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 300
```

## Development Notes

### Legacy Python Components
The `requirements.txt` contains Flask dependencies from a previous architecture:
- Flask 2.3.3, Flask-SQLAlchemy, Flask-JWT-Extended, etc.
- These are no longer used in the current WordPress-based system
- The compiled `app.cpython-312.pyc` file exists but the source is not present

### Database Migrations
The plugin handles schema updates automatically via `dbDelta()` and includes migration logic for older table structures.

### Error Logging
Plugin logs activation and setup steps to WordPress debug log when `WP_DEBUG_LOG` is enabled.

## API Usage Examples

### Get Routes with Filtering
```bash
# Get all routes
curl -X GET "https://yoursite.com/wp-json/crux/v1/routes" \
  -H "X-WordPress-Cookie: wordpress_logged_in_hash=user|exp|token|hmac"

# Filter by wall section
curl -X GET "https://yoursite.com/wp-json/crux/v1/routes?wall_section=Main Wall"

# Filter by grade  
curl -X GET "https://yoursite.com/wp-json/crux/v1/routes?grade=6a%2B"
```

### Create Route (Route Setter/Admin)
```bash
curl -X POST "https://yoursite.com/wp-json/crux/v1/routes" \
  -H "Content-Type: application/json" \
  -H "X-WordPress-Cookie: wordpress_logged_in_hash=user|exp|token|hmac" \
  -d '{
    "name": "Crimpy Goodness",
    "grade_id": 15,
    "route_setter": "John Doe", 
    "wall_section": "Main Wall",
    "lane_id": 5,
    "hold_color_id": 1,
    "description": "Technical route with small holds"
  }'
```

### Tick a Route
```bash
curl -X POST "https://yoursite.com/wp-json/crux/v1/routes/123/ticks" \
  -H "Content-Type: application/json" \
  -H "X-WordPress-Cookie: wordpress_logged_in_hash=user|exp|token|hmac" \
  -d '{
    "attempts": 3,
    "flash": false,
    "notes": "Great route, pumpy finish!"
  }'
```

This WordPress-based backend provides a robust, scalable foundation for climbing gym management with comprehensive API support for mobile and web applications.