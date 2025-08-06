from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_bcrypt import Bcrypt
from datetime import datetime, timedelta
import os
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# CORS configuration to handle JWT tokens properly
CORS(app, resources={
    r"/api/*": {
        "origins": ["http://localhost:3000", "http://127.0.0.1:3000"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

# Configuration
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{os.path.join(basedir, "climbing_gym.db")}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', 'your-secret-key-change-this-in-production')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=1)
app.config['JWT_ALGORITHM'] = 'HS256'  # Explicitly set algorithm

# Initialize extensions
db = SQLAlchemy(app)
jwt = JWTManager(app)

# Add request logging middleware
@app.before_request
def log_request():
    logger.debug(f"Request: {request.method} {request.path}")
    auth_header = request.headers.get('Authorization')
    if auth_header:
        logger.debug(f"Authorization header: {auth_header[:20]}...")  # Don't log full token
    
@app.after_request
def log_response(response):
    logger.debug(f"Response: {response.status_code}")
    return response
bcrypt = Bcrypt(app)

# Helper function to get current user ID as integer
def get_current_user_id():
    """Get the current user ID from JWT token as an integer"""
    user_id_str = get_jwt_identity()
    return int(user_id_str) if user_id_str else None

# JWT Error handlers
@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    return jsonify({'error': 'Token has expired'}), 401

@jwt.invalid_token_loader
def invalid_token_callback(error):
    print(f"Invalid token error: {error}")
    return jsonify({'error': 'Invalid token', 'details': str(error)}), 422

@jwt.unauthorized_loader
def missing_token_callback(error):
    print(f"Missing token error: {error}")
    return jsonify({'error': 'Authorization token is required', 'details': str(error)}), 401

# Add a test route to verify JWT is working
@app.route('/api/test-auth', methods=['GET'])
@jwt_required()
def test_auth():
    """Test route to verify JWT authentication"""
    user_id = get_current_user_id()
    user = User.query.get(user_id)
    return jsonify({
        'message': 'Authentication successful',
        'user_id': user_id,
        'username': user.username if user else 'Unknown'
    })

# Models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)
    
    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
    
    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat(),
            'is_active': self.is_active
        }
class Route(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    grade = db.Column(db.String(10), nullable=False)
    route_setter = db.Column(db.String(100), nullable=False)
    wall_section = db.Column(db.String(50), nullable=False)
    lane = db.Column(db.Integer, nullable=False)
    color = db.Column(db.String(20), nullable=True)
    description = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    likes = db.relationship('Like', backref='route', lazy=True, cascade='all, delete-orphan')
    comments = db.relationship('Comment', backref='route', lazy=True, cascade='all, delete-orphan')
    grade_proposals = db.relationship('GradeProposal', backref='route', lazy=True, cascade='all, delete-orphan')
    warnings = db.relationship('Warning', backref='route', lazy=True, cascade='all, delete-orphan')
    ticks = db.relationship('Tick', backref='route', lazy=True, cascade='all, delete-orphan')
    ticks = db.relationship('Tick', backref='route', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'grade': self.grade,
            'route_setter': self.route_setter,
            'wall_section': self.wall_section,
            'lane': self.lane,
            'color': self.color,
            'description': self.description,
            'created_at': self.created_at.isoformat(),
            'likes_count': len(self.likes),
            'comments_count': len(self.comments),
            'grade_proposals_count': len(self.grade_proposals),
            'warnings_count': len(self.warnings),
            'ticks_count': len(self.ticks)
        }

class Like(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.now(datetime.timezone.utc))
    
    # Relationships
    user = db.relationship('User', backref='likes')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.username,
            'route_id': self.route_id,
            'created_at': self.created_at.isoformat()
        }

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    content = db.Column(db.Text, nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='comments')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.username,
            'content': self.content,
            'route_id': self.route_id,
            'created_at': self.created_at.isoformat()
        }

class GradeProposal(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    proposed_grade = db.Column(db.String(10), nullable=False)
    reasoning = db.Column(db.Text, nullable=True)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='grade_proposals')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.username,
            'proposed_grade': self.proposed_grade,
            'reasoning': self.reasoning,
            'route_id': self.route_id,
            'created_at': self.created_at.isoformat()
        }

class Warning(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    warning_type = db.Column(db.String(50), nullable=False)  # e.g., 'broken_hold', 'safety_issue', 'needs_cleaning'
    description = db.Column(db.Text, nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    status = db.Column(db.String(20), default='open')  # 'open', 'acknowledged', 'resolved'
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='warnings')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.username,
            'warning_type': self.warning_type,
            'description': self.description,
            'route_id': self.route_id,
            'status': self.status,
            'created_at': self.created_at.isoformat()
        }

class Tick(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    attempts = db.Column(db.Integer, default=1)  # Number of attempts to complete
    flash = db.Column(db.Boolean, default=False)  # True if completed on first try
    notes = db.Column(db.Text, nullable=True)  # Optional notes about the ascent
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='ticks')

    # Ensure one tick per user per route
    __table_args__ = (db.UniqueConstraint('user_id', 'route_id', name='unique_user_route_tick'),)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.username,
            'route_id': self.route_id,
            'attempts': self.attempts,
            'flash': self.flash,
            'notes': self.notes,
            'created_at': self.created_at.isoformat()
        }
# API Routes

# Authentication Routes
@app.route('/api/auth/register', methods=['POST'])
def register():
    """Register a new user"""
    data = request.get_json()
    
    # Validate required fields
    if not data.get('username') or not data.get('email') or not data.get('password'):
        return jsonify({'error': 'Username, email, and password are required'}), 400
    
    # Check if user already exists
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already exists'}), 400
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already exists'}), 400
    
    # Create new user
    user = User(
        username=data['username'],
        email=data['email']
    )
    user.set_password(data['password'])
    
    db.session.add(user)
    db.session.commit()
    
    # Create access token - convert user ID to string
    access_token = create_access_token(identity=str(user.id))
    
    return jsonify({
        'message': 'User registered successfully',
        'access_token': access_token,
        'user': user.to_dict()
    }), 201

@app.route('/api/auth/login', methods=['POST'])
def login():
    """Login user"""
    data = request.get_json()
    
    # Validate required fields
    if not data.get('username') or not data.get('password'):
        return jsonify({'error': 'Username and password are required'}), 400
    
    # Find user
    user = User.query.filter_by(username=data['username']).first()
    
    if not user or not user.check_password(data['password']):
        return jsonify({'error': 'Invalid username or password'}), 401
    
    if not user.is_active:
        return jsonify({'error': 'Account is disabled'}), 401
    
    # Create access token - convert user ID to string
    access_token = create_access_token(identity=str(user.id))
    
    return jsonify({
        'message': 'Login successful',
        'access_token': access_token,
        'user': user.to_dict()
    }), 200

@app.route('/api/auth/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """Get current user information"""
    user_id = get_current_user_id()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    return jsonify({'user': user.to_dict()}), 200

# API Routes

@app.route('/api/routes', methods=['GET'])
@jwt_required()
def get_routes():
    """Get all routes with optional filtering"""
    wall_section = request.args.get('wall_section')
    grade = request.args.get('grade')
    lane = request.args.get('lane')
    
    query = Route.query
    if wall_section:
        query = query.filter(Route.wall_section == wall_section)
    if grade:
        query = query.filter(Route.grade == grade)
    if lane:
        query = query.filter(Route.lane == int(lane))
    
    routes = query.all()
    return jsonify([route.to_dict() for route in routes])

@app.route('/api/routes/<int:route_id>', methods=['GET'])
@jwt_required()
def get_route(route_id):
    """Get a specific route with all details"""
    route = Route.query.get_or_404(route_id)
    route_data = route.to_dict()
    
    # Add detailed information
    route_data['likes'] = [like.to_dict() for like in route.likes]
    route_data['comments'] = [comment.to_dict() for comment in route.comments]
    route_data['grade_proposals'] = [proposal.to_dict() for proposal in route.grade_proposals]
    route_data['warnings'] = [warning.to_dict() for warning in route.warnings]
    route_data['ticks'] = [tick.to_dict() for tick in route.ticks]
    
    return jsonify(route_data)

@app.route('/api/routes', methods=['POST'])
@jwt_required()
def create_route():
    """Create a new route"""
    data = request.get_json()
    
    route = Route(
        name=data['name'],
        grade=data['grade'],
        route_setter=data['route_setter'],
        wall_section=data['wall_section'],
        lane=data['lane'],
        color=data.get('color'),
        description=data.get('description')
    )
    
    db.session.add(route)
    db.session.commit()
    
    return jsonify(route.to_dict()), 201

@app.route('/api/routes/<int:route_id>/like', methods=['POST'])
@jwt_required()
def like_route(route_id):
    """Like a route"""
    user_id = get_current_user_id()
    
    # Check if user already liked this route
    existing_like = Like.query.filter_by(route_id=route_id, user_id=user_id).first()
    if existing_like:
        return jsonify({'message': 'Already liked'}), 400
    
    like = Like(route_id=route_id, user_id=user_id)
    db.session.add(like)
    db.session.commit()
    
    return jsonify(like.to_dict()), 201

@app.route('/api/routes/<int:route_id>/unlike', methods=['DELETE'])
@jwt_required()
def unlike_route(route_id):
    """Unlike a route"""
    user_id = get_current_user_id()
    
    like = Like.query.filter_by(route_id=route_id, user_id=user_id).first()
    if not like:
        return jsonify({'message': 'Like not found'}), 404
    
    db.session.delete(like)
    db.session.commit()
    
    return jsonify({'message': 'Unliked successfully'}), 200

@app.route('/api/routes/<int:route_id>/comments', methods=['POST'])
@jwt_required()
def add_comment(route_id):
    """Add a comment to a route"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    comment = Comment(
        route_id=route_id,
        user_id=user_id,
        content=data['content']
    )
    
    db.session.add(comment)
    db.session.commit()
    
    return jsonify(comment.to_dict()), 201

@app.route('/api/routes/<int:route_id>/grade-proposals', methods=['POST'])
@jwt_required()
def propose_grade(route_id):
    """Propose a different grade for a route"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    proposal = GradeProposal(
        route_id=route_id,
        user_id=user_id,
        proposed_grade=data['proposed_grade'],
        reasoning=data.get('reasoning')
    )
    
    db.session.add(proposal)
    db.session.commit()
    
    return jsonify(proposal.to_dict()), 201

@app.route('/api/routes/<int:route_id>/warnings', methods=['POST'])
@jwt_required()
def add_warning(route_id):
    """Add a warning for a route"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    warning = Warning(
        route_id=route_id,
        user_id=user_id,
        warning_type=data['warning_type'],
        description=data['description']
    )
    
    db.session.add(warning)
    db.session.commit()
    
    return jsonify(warning.to_dict()), 201

@app.route('/api/routes/<int:route_id>/ticks', methods=['POST'])
@jwt_required()
def add_tick(route_id):
    """Add a tick (successful ascent) for a route"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    # Check if user already ticked this route
    existing_tick = Tick.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if existing_tick:
        return jsonify({'error': 'Route already ticked by this user'}), 400
    
    tick = Tick(
        route_id=route_id,
        user_id=user_id,
        attempts=data.get('attempts', 1),
        flash=data.get('flash', False),
        notes=data.get('notes')
    )
    
    db.session.add(tick)
    db.session.commit()
    
    return jsonify(tick.to_dict()), 201

@app.route('/api/routes/<int:route_id>/ticks', methods=['DELETE'])
@jwt_required()
def remove_tick(route_id):
    """Remove a tick for a route"""
    user_id = get_jwt_identity()
    
    tick = Tick.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if not tick:
        return jsonify({'error': 'Tick not found'}), 404
    
    db.session.delete(tick)
    db.session.commit()
    
    return jsonify({'message': 'Tick removed successfully'}), 200

@app.route('/api/routes/<int:route_id>/ticks/me', methods=['GET'])
@jwt_required()
def get_user_tick(route_id):
    """Get current user's tick for a route"""
    user_id = get_jwt_identity()
    
    tick = Tick.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if not tick:
        return jsonify({'ticked': False}), 200
    
    return jsonify({
        'ticked': True,
        'tick': tick.to_dict()
    }), 200

@app.route('/api/wall-sections', methods=['GET'])
@jwt_required()
def get_wall_sections():
    """Get all unique wall sections"""
    sections = db.session.query(Route.wall_section).distinct().all()
    return jsonify([section[0] for section in sections])

@app.route('/api/grades', methods=['GET'])
@jwt_required()
def get_grades():
    """Get all unique grades"""
    grades = db.session.query(Route.grade).distinct().all()
    return jsonify([grade[0] for grade in grades])

@app.route('/api/lanes', methods=['GET'])
@jwt_required()
def get_lanes():
    """Get all unique lanes"""
    lanes = db.session.query(Route.lane).distinct().order_by(Route.lane).all()
    return jsonify([lane[0] for lane in lanes])

# User Profile Routes
@app.route('/api/user/ticks', methods=['GET'])
@jwt_required()
def get_user_ticks():
    """Get all ticks for the current user with route details"""
    user_id = get_current_user_id()
    
    # Join ticks with routes to get route details
    ticks_with_routes = db.session.query(Tick, Route).join(Route).filter(
        Tick.user_id == user_id
    ).order_by(Tick.created_at.desc()).all()
    
    result = []
    for tick, route in ticks_with_routes:
        tick_data = tick.to_dict()
        tick_data['route_name'] = route.name
        tick_data['route_grade'] = route.grade
        tick_data['wall_section'] = route.wall_section
        result.append(tick_data)
    
    return jsonify(result)

@app.route('/api/user/likes', methods=['GET'])
@jwt_required()
def get_user_likes():
    """Get all likes for the current user with route details"""
    user_id = get_current_user_id()
    
    # Join likes with routes to get route details
    likes_with_routes = db.session.query(Like, Route).join(Route).filter(
        Like.user_id == user_id
    ).order_by(Like.created_at.desc()).all()
    
    result = []
    for like, route in likes_with_routes:
        like_data = like.to_dict()
        like_data['route_name'] = route.name
        like_data['route_grade'] = route.grade
        like_data['wall_section'] = route.wall_section
        result.append(like_data)
    
    return jsonify(result)

@app.route('/api/user/stats', methods=['GET'])
@jwt_required()
def get_user_stats():
    """Get comprehensive user statistics"""
    user_id = get_current_user_id()
    
    # Get all user activities
    ticks = Tick.query.filter_by(user_id=user_id).all()
    likes = Like.query.filter_by(user_id=user_id).all()
    comments = Comment.query.filter_by(user_id=user_id).all()
    
    # Calculate statistics
    total_ticks = len(ticks)
    total_likes = len(likes)
    total_comments = len(comments)
    total_flashes = sum(1 for tick in ticks if tick.flash)
    total_attempts = sum(tick.attempts for tick in ticks)
    average_attempts = total_attempts / total_ticks if total_ticks > 0 else 0
    
    # Get achieved grades (from ticks)
    achieved_grades = list(set([
        Route.query.get(tick.route_id).grade for tick in ticks
    ]))
    
    # Find hardest grade (simple V-scale logic)
    hardest_grade = None
    if achieved_grades:
        v_grades = [grade for grade in achieved_grades if grade.startswith('V')]
        if v_grades:
            v_numbers = [int(grade[1:]) for grade in v_grades if grade[1:].isdigit()]
            if v_numbers:
                hardest_number = max(v_numbers)
                hardest_grade = f'V{hardest_number}'
    
    # Get unique wall sections
    unique_wall_sections = len(set([
        Route.query.get(tick.route_id).wall_section for tick in ticks
    ]))
    
    return jsonify({
        'total_ticks': total_ticks,
        'total_likes': total_likes,
        'total_comments': total_comments,
        'total_flashes': total_flashes,
        'average_attempts': round(average_attempts, 2),
        'hardest_grade': hardest_grade,
        'unique_wall_sections': unique_wall_sections,
        'achieved_grades': sorted(achieved_grades, key=lambda x: int(x[1:]) if x.startswith('V') and x[1:].isdigit() else 0)
    })

# Initialize database
def init_db():
    """Initialize database with sample data"""
    db.create_all()
    
    # Check if we already have data
    if User.query.first():
        return
    
    # Create sample users
    admin_user = User(username='admin', email='admin@climbing-gym.com')
    admin_user.set_password('admin123')
    
    alice = User(username='alice_johnson', email='alice@example.com')
    alice.set_password('password123')
    
    bob = User(username='bob_smith', email='bob@example.com')
    bob.set_password('password123')
    
    charlie = User(username='charlie_brown', email='charlie@example.com')
    charlie.set_password('password123')
    
    db.session.add_all([admin_user, alice, bob, charlie])
    db.session.commit()
    
    # Sample routes
    sample_routes = [
        Route(name="Crimpy Goodness", grade="V4", route_setter="Alice Johnson", wall_section="Overhang Wall", lane=1, color="Red", description="Technical crimps with a dynamic finish"),
        Route(name="Slab Master", grade="V2", route_setter="Bob Smith", wall_section="Slab Wall", lane=3, color="Blue", description="Balance and footwork focused"),
        Route(name="Power House", grade="V6", route_setter="Charlie Brown", wall_section="Steep Wall", lane=2, color="Yellow", description="Raw power moves with big holds"),
        Route(name="Finger Torture", grade="V5", route_setter="Diana Prince", wall_section="Overhang Wall", lane=4, color="Green", description="Tiny crimps and pinches"),
        Route(name="Beginner's Delight", grade="V1", route_setter="Eve Wilson", wall_section="Vertical Wall", lane=1, color="Orange", description="Perfect for new climbers"),
        Route(name="The Gaston", grade="V3", route_setter="Frank Miller", wall_section="Vertical Wall", lane=2, color="Purple", description="Lots of gaston moves"),
    ]
    
    for route in sample_routes:
        db.session.add(route)
    
    db.session.commit()
    print("Database initialized with sample data!")
    print("Sample users created:")
    print("- admin / admin123")
    print("- alice_johnson / password123")
    print("- bob_smith / password123")
    print("- charlie_brown / password123")

if __name__ == '__main__':
    with app.app_context():
        init_db()
    app.run(debug=True, host='0.0.0.0', port=5000)
