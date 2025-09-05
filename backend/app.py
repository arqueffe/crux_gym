from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_bcrypt import Bcrypt
from datetime import datetime, timedelta, timezone
import os
import logging
# Add sqlalchemy func import for case-insensitive checks
from sqlalchemy import func

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
        'username': user.username if user else 'Unknown',
        'nickname': user.nickname if user else 'Unknown'
    })

# Helper function to get current user ID as integer

# Models
class Grade(db.Model):
    __tablename__ = 'grades'
    id = db.Column(db.Integer, primary_key=True)
    grade = db.Column(db.String(10), unique=True, nullable=False)
    difficulty_order = db.Column(db.Integer, nullable=False)  # For sorting
    color = db.Column(db.String(7), nullable=False)  # Hex color code
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'grade': self.grade,
            'difficulty_order': self.difficulty_order,
            'color': self.color,
            'created_at': self.created_at.isoformat()
        }

class HoldColor(db.Model):
    __tablename__ = 'hold_colors'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    hex_code = db.Column(db.String(7), nullable=True)  # Optional hex representation
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'hex_code': self.hex_code,
            'created_at': self.created_at.isoformat()
        }

class Lane(db.Model):
    __tablename__ = 'lanes'
    id = db.Column(db.Integer, primary_key=True)
    number = db.Column(db.Integer, unique=True, nullable=False)
    name = db.Column(db.String(50), nullable=True)  # Optional name like "Lane 1", "Center Route"
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'number': self.number,
            'name': self.name or f"Lane {self.number}",
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat()
        }

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    # Public display name
    nickname = db.Column(db.String(80), nullable=False)
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
            'nickname': self.nickname,
            'email': self.email,
            'created_at': self.created_at.isoformat(),
            'is_active': self.is_active
        }
class Route(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    grade_id = db.Column(db.Integer, db.ForeignKey('grades.id'), nullable=False)
    route_setter = db.Column(db.String(100), nullable=False)
    wall_section = db.Column(db.String(50), nullable=False)
    lane_id = db.Column(db.Integer, db.ForeignKey('lanes.id'), nullable=False)
    hold_color_id = db.Column(db.Integer, db.ForeignKey('hold_colors.id'), nullable=True)
    description = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    grade_rel = db.relationship('Grade', backref='routes')
    lane_rel = db.relationship('Lane', backref='routes')
    hold_color_rel = db.relationship('HoldColor', backref='routes')
    likes = db.relationship('Like', backref='route', lazy=True, cascade='all, delete-orphan')
    comments = db.relationship('Comment', backref='route', lazy=True, cascade='all, delete-orphan')
    grade_proposals = db.relationship('GradeProposal', backref='route', lazy=True, cascade='all, delete-orphan')
    warnings = db.relationship('Warning', backref='route', lazy=True, cascade='all, delete-orphan')
    ticks = db.relationship('Tick', backref='route', lazy=True, cascade='all, delete-orphan')
    # Note: Project relationship will be added by the Project model's backref

    def to_dict(self):
        # Calculate counts using database queries for accuracy
        from sqlalchemy import func
        likes_count = db.session.query(func.count(Like.id)).filter(Like.route_id == self.id).scalar() or 0
        comments_count = db.session.query(func.count(Comment.id)).filter(Comment.route_id == self.id).scalar() or 0
        grade_proposals_count = db.session.query(func.count(GradeProposal.id)).filter(GradeProposal.route_id == self.id).scalar() or 0
        warnings_count = db.session.query(func.count(Warning.id)).filter(Warning.route_id == self.id).scalar() or 0
        ticks_count = db.session.query(func.count(Tick.id)).filter(Tick.route_id == self.id).scalar() or 0
        projects_count = db.session.query(func.count(Project.id)).filter(Project.route_id == self.id).scalar() or 0

        return {
            'id': self.id,
            'name': self.name,
            'grade': self.grade_rel.grade if self.grade_rel else None,
            'grade_color': self.grade_rel.color if self.grade_rel else '#888888',
            'route_setter': self.route_setter,
            'wall_section': self.wall_section,
            'lane': self.lane_rel.number if self.lane_rel else None,
            'lane_name': self.lane_rel.name if self.lane_rel else None,
            'color': self.hold_color_rel.name if self.hold_color_rel else None,
            'color_hex': self.hold_color_rel.hex_code if self.hold_color_rel else None,
            'description': self.description,
            'created_at': self.created_at.isoformat(),
            'likes_count': likes_count,
            'comments_count': comments_count,
            'grade_proposals_count': grade_proposals_count,
            'warnings_count': warnings_count,
            'ticks_count': ticks_count,
            'projects_count': projects_count
        }

class Like(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    
    # Relationships
    user = db.relationship('User', backref='likes')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.nickname or self.user.username,
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
            'user_name': self.user.nickname or self.user.username,
            'content': self.content,
            'route_id': self.route_id,
            'created_at': self.created_at.isoformat()
        }

class GradeProposal(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    proposed_grade_id = db.Column(db.Integer, db.ForeignKey('grades.id'), nullable=False)
    reasoning = db.Column(db.Text, nullable=True)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='grade_proposals')
    proposed_grade_rel = db.relationship('Grade', backref='proposals')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.nickname or self.user.username,
            'proposed_grade': self.proposed_grade_rel.grade if self.proposed_grade_rel else None,
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
            'user_name': self.user.nickname or self.user.username,
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
    
    # Attempt tracking
    attempts = db.Column(db.Integer, default=0)  # Total number of attempts
    
    # Send types (independent tracking)
    top_rope_send = db.Column(db.Boolean, default=False)  # Successfully sent on top rope
    lead_send = db.Column(db.Boolean, default=False)  # Successfully sent on lead
    top_rope_flash = db.Column(db.Boolean, default=False)  # Top rope flash (first try)
    lead_flash = db.Column(db.Boolean, default=False)  # Lead flash (first try)
    
    # Legacy field for backward compatibility
    flash = db.Column(db.Boolean, default=False)  # True if completed on first try (any style)
    
    notes = db.Column(db.Text, nullable=True)  # Optional notes about the ascent
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='ticks')

    # Ensure one tick per user per route
    __table_args__ = (db.UniqueConstraint('user_id', 'route_id', name='unique_user_route_tick'),)

    @property
    def has_any_send(self):
        """Check if user has sent the route in any style"""
        return self.top_rope_send or self.lead_send

    @property
    def has_any_flash(self):
        """Check if user has flashed the route in any style"""
        return self.top_rope_flash or self.lead_flash

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.nickname or self.user.username,
            'route_id': self.route_id,
            'attempts': self.attempts,
            'top_rope_send': self.top_rope_send,
            'lead_send': self.lead_send,
            'top_rope_flash': self.top_rope_flash,
            'lead_flash': self.lead_flash,
            'flash': self.flash,  # Legacy field
            'has_any_send': self.has_any_send,
            'has_any_flash': self.has_any_flash,
            'notes': self.notes,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

class Project(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    notes = db.Column(db.Text, nullable=True)  # Optional notes about the project
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref='projects')
    route = db.relationship('Route', backref='projects')

    # Ensure one project per user per route
    __table_args__ = (db.UniqueConstraint('user_id', 'route_id', name='unique_user_route_project'),)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'user_name': self.user.nickname or self.user.username,
            'route_id': self.route_id,
            'route_name': self.route.name if self.route else None,
            'route_grade': self.route.grade_rel.grade if self.route and self.route.grade_rel else None,
            'route_wall_section': self.route.wall_section if self.route else None,
            'notes': self.notes,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

# API Routes

# Authentication Routes
@app.route('/api/auth/register', methods=['POST'])
def register():
    """Register a new user"""
    data = request.get_json()
    
    # Validate required fields
    if not data.get('username') or not data.get('email') or not data.get('password') or not data.get('nickname'):
        return jsonify({'error': 'Username, nickname, email, and password are required'}), 400

    # Validate nickname constraints (3-20 chars, alphanumeric + underscore)
    nickname = data['nickname']
    if not (3 <= len(nickname) <= 20):
        return jsonify({'error': 'Nickname must be between 3 and 20 characters'}), 400
    import re
    if not re.match(r'^[A-Za-z0-9_]+$', nickname):
        return jsonify({'error': 'Nickname can contain only letters, numbers, and underscores'}), 400
    
    # Check if user already exists
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already exists'}), 400
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already exists'}), 400

    # Case-insensitive nickname uniqueness
    if db.session.query(User.id).filter(func.lower(User.nickname) == nickname.lower()).first():
        return jsonify({'error': 'Nickname already taken'}), 400
    
    # Create new user
    user = User(
        username=data['username'],
        nickname=nickname,
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
    
    query = db.session.query(Route).join(Grade, Route.grade_id == Grade.id).join(Lane, Route.lane_id == Lane.id)
    
    if wall_section:
        query = query.filter(Route.wall_section == wall_section)
    if grade:
        query = query.filter(Grade.grade == grade)
    if lane:
        query = query.filter(Lane.number == int(lane))
    
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
    
    # Validate required fields
    required_fields = ['name', 'grade', 'route_setter', 'wall_section', 'lane']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} is required'}), 400
    
    # Find grade in database
    grade = Grade.query.filter_by(grade=data['grade']).first()
    if not grade:
        available_grades = [g.grade for g in Grade.query.order_by(Grade.difficulty_order).all()]
        return jsonify({
            'error': f"Invalid grade: {data['grade']}. Must be one of the available grades.",
            'available_grades': available_grades
        }), 400
    
    # Find hold color if provided
    hold_color = None
    if data.get('color'):
        hold_color = HoldColor.query.filter_by(name=data['color']).first()
        if not hold_color:
            available_colors = [c.name for c in HoldColor.query.all()]
            return jsonify({
                'error': f"Invalid color: {data['color']}. Must be one of the available hold colors.",
                'available_colors': available_colors
            }), 400
    
    # Find lane in database
    lane = Lane.query.filter_by(number=int(data['lane'])).first()
    if not lane:
        available_lanes = [l.number for l in Lane.query.filter_by(is_active=True).order_by(Lane.number).all()]
        return jsonify({
            'error': f"Invalid lane: {data['lane']}. Must be one of the available lanes.",
            'available_lanes': available_lanes
        }), 400

    try:
        route = Route(
            name=data['name'],
            grade_id=grade.id,
            route_setter=data['route_setter'],
            wall_section=data['wall_section'],
            lane_id=lane.id,
            hold_color_id=hold_color.id if hold_color else None,
            description=data.get('description')
        )
        
        db.session.add(route)
        db.session.commit()
        
        return jsonify(route.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to create route'}), 500

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
    """Propose a different grade for a route (creates new or updates existing proposal)"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    # Validate proposed grade
    proposed_grade_str = data.get('proposed_grade')
    if not proposed_grade_str:
        return jsonify({'error': 'proposed_grade is required'}), 400
    
    # Find grade in database
    proposed_grade = Grade.query.filter_by(grade=proposed_grade_str).first()
    if not proposed_grade:
        available_grades = [g.grade for g in Grade.query.order_by(Grade.difficulty_order).all()]
        return jsonify({
            'error': f"Invalid proposed grade: {proposed_grade_str}. Must be one of the available grades.",
            'available_grades': available_grades
        }), 400
    
    # Check if user already has a proposal for this route
    existing_proposal = GradeProposal.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if existing_proposal:
        # Update existing proposal
        existing_proposal.proposed_grade_id = proposed_grade.id
        existing_proposal.reasoning = data.get('reasoning')
        existing_proposal.created_at = datetime.utcnow()  # Update timestamp
        proposal = existing_proposal
    else:
        # Create new proposal
        proposal = GradeProposal(
            route_id=route_id,
            user_id=user_id,
            proposed_grade_id=proposed_grade.id,
            reasoning=data.get('reasoning')
        )
        db.session.add(proposal)
    
    db.session.commit()
    
    return jsonify(proposal.to_dict()), 201

@app.route('/api/routes/<int:route_id>/grade-proposals/user', methods=['GET'])
@jwt_required()
def get_user_grade_proposal(route_id):
    """Get current user's grade proposal for a route"""
    user_id = get_jwt_identity()
    
    proposal = GradeProposal.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if proposal:
        return jsonify(proposal.to_dict()), 200
    else:
        return jsonify({'message': 'No proposal found for this user'}), 404

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
def add_or_update_tick(route_id):
    """Add or update a tick for a route with attempts and send types"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    # Check if user already has a tick for this route
    existing_tick = Tick.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if existing_tick:
        # Update existing tick
        tick = existing_tick
        tick.updated_at = datetime.utcnow()
    else:
        # Create new tick
        tick = Tick(
            route_id=route_id,
            user_id=user_id
        )
    
    # Update attempts (incremental or absolute)
    if 'add_attempts' in data:
        tick.attempts = (tick.attempts or 0) + data.get('add_attempts', 0)
    elif 'attempts' in data:
        tick.attempts = data.get('attempts', tick.attempts or 0)
    
    # Update send types
    if 'top_rope_send' in data:
        tick.top_rope_send = data.get('top_rope_send', False)
    if 'lead_send' in data:
        tick.lead_send = data.get('lead_send', False)
        # Remove project status when lead sent (a sent route cannot be a project)
        if tick.lead_send:
            project = Project.query.filter_by(route_id=route_id, user_id=user_id).first()
            if project:
                db.session.delete(project)
    if 'top_rope_flash' in data:
        tick.top_rope_flash = data.get('top_rope_flash', False)
    if 'lead_flash' in data:
        tick.lead_flash = data.get('lead_flash', False)
    
    # Update legacy flash field (for backward compatibility)
    if 'flash' in data:
        tick.flash = data.get('flash', False)
    
    # Auto-set flash fields if sends are marked and attempts are 1
    if tick.attempts == 1:
        if tick.top_rope_send and not tick.top_rope_flash:
            tick.top_rope_flash = True
        if tick.lead_send and not tick.lead_flash:
            tick.lead_flash = True
    
    # Update notes
    if 'notes' in data:
        tick.notes = data.get('notes')
    
    if not existing_tick:
        db.session.add(tick)
    
    db.session.commit()
    
    return jsonify(tick.to_dict()), 201 if not existing_tick else 200

@app.route('/api/routes/<int:route_id>/attempts', methods=['POST'])
@jwt_required()
def add_attempts(route_id):
    """Add attempts to a route without marking as sent"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    attempts_to_add = data.get('attempts', 1)
    if attempts_to_add < 1:
        return jsonify({'error': 'Attempts must be at least 1'}), 400
    
    # Get or create tick record
    tick = Tick.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if tick:
        tick.attempts = (tick.attempts or 0) + attempts_to_add
        tick.updated_at = datetime.utcnow()
    else:
        tick = Tick(
            route_id=route_id,
            user_id=user_id,
            attempts=attempts_to_add
        )
        db.session.add(tick)
    
    # Update notes if provided
    if 'notes' in data:
        tick.notes = data.get('notes')
    
    db.session.commit()
    
    return jsonify(tick.to_dict()), 200

@app.route('/api/routes/<int:route_id>/send', methods=['POST'])
@jwt_required()
def mark_send(route_id):
    """Mark a route as sent in a specific style"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    send_type = data.get('send_type')  # 'top_rope' or 'lead'
    if send_type not in ['top_rope', 'lead']:
        return jsonify({'error': 'send_type must be "top_rope" or "lead"'}), 400
    
    # Get or create tick record
    tick = Tick.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if not tick:
        tick = Tick(
            route_id=route_id,
            user_id=user_id,
            attempts=1  # Default to 1 attempt if this is the first record
        )
        db.session.add(tick)
    
    # Mark the appropriate send type
    if send_type == 'top_rope':
        tick.top_rope_send = True
        # Check if it's a flash (first attempt)
        if tick.attempts <= 1:
            tick.top_rope_flash = True
            tick.flash = True  # Legacy field
    elif send_type == 'lead':
        tick.lead_send = True
        # Check if it's a flash (first attempt)
        if tick.attempts <= 1:
            tick.lead_flash = True
            tick.flash = True  # Legacy field
        
        # Remove project status when lead sent (a sent route cannot be a project)
        project = Project.query.filter_by(route_id=route_id, user_id=user_id).first()
        if project:
            db.session.delete(project)
    
    tick.updated_at = datetime.utcnow()
    
    # Update notes if provided
    if 'notes' in data:
        tick.notes = data.get('notes')
    
    db.session.commit()
    
    return jsonify(tick.to_dict()), 200

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

# Project Endpoints

@app.route('/api/routes/<int:route_id>/projects', methods=['POST'])
@jwt_required()
def add_project(route_id):
    """Mark a route as a project"""
    user_id = get_current_user_id()
    
    # Check if route exists
    route = Route.query.get_or_404(route_id)
    
    # Check if user has already lead sent this route
    tick = Tick.query.filter_by(route_id=route_id, user_id=user_id).first()
    if tick and tick.lead_send:
        return jsonify({'error': 'Cannot mark sent routes as projects. You have already lead sent this route.'}), 400
    
    # Check if route is already marked as project
    existing_project = Project.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if existing_project:
        return jsonify({'error': 'Route already marked as project'}), 400
    
    data = request.get_json() or {}
    
    try:
        project = Project(
            route_id=route_id,
            user_id=user_id,
            notes=data.get('notes')
        )
        
        db.session.add(project)
        db.session.commit()
        
        return jsonify(project.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to add project'}), 500

@app.route('/api/routes/<int:route_id>/projects', methods=['DELETE'])
@jwt_required()
def remove_project(route_id):
    """Remove route from projects"""
    user_id = get_current_user_id()
    
    project = Project.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if not project:
        return jsonify({'error': 'Route not marked as project'}), 404
    
    try:
        db.session.delete(project)
        db.session.commit()
        
        return jsonify({'message': 'Project removed successfully'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to remove project'}), 500

@app.route('/api/routes/<int:route_id>/projects/me', methods=['GET'])
@jwt_required()
def get_user_project_status(route_id):
    """Check if the current user has marked this route as a project"""
    user_id = get_jwt_identity()
    
    project = Project.query.filter_by(
        route_id=route_id,
        user_id=user_id
    ).first()
    
    if not project:
        return jsonify({'is_project': False}), 200
    
    return jsonify({
        'is_project': True,
        'project': project.to_dict()
    }), 200

@app.route('/api/user/projects', methods=['GET'])
@jwt_required()
def get_user_projects():
    """Get all projects for the current user"""
    user_id = get_current_user_id()
    
    projects = Project.query.filter_by(user_id=user_id).all()
    
    return jsonify([project.to_dict() for project in projects]), 200

@app.route('/api/wall-sections', methods=['GET'])
@jwt_required()
def get_wall_sections():
    """Get all unique wall sections"""
    sections = db.session.query(Route.wall_section).distinct().all()
    return jsonify([section[0] for section in sections])

@app.route('/api/grades', methods=['GET'])
@jwt_required()
def get_grades():
    """Get all unique grades from the database"""
    grades = Grade.query.order_by(Grade.difficulty_order).all()
    return jsonify([grade.grade for grade in grades])

@app.route('/api/lanes', methods=['GET'])
@jwt_required()
def get_lanes():
    """Get all available lanes from database"""
    lanes = Lane.query.filter_by(is_active=True).order_by(Lane.number).all()
    return jsonify([lane.to_dict() for lane in lanes])

@app.route('/api/grade-definitions', methods=['GET'])
@jwt_required()
def get_grade_definitions():
    """Get all available climbing grades with colors from database"""
    grades = Grade.query.order_by(Grade.difficulty_order).all()
    return jsonify([grade.to_dict() for grade in grades])

@app.route('/api/hold-colors', methods=['GET'])
@jwt_required()
def get_hold_colors():
    """Get all available hold colors from database"""
    hold_colors = HoldColor.query.all()
    return jsonify([color.to_dict() for color in hold_colors])

@app.route('/api/grade-colors', methods=['GET'])
@jwt_required()
def get_grade_colors():
    """Get grade to color mapping from database"""
    grades = Grade.query.all()
    grade_colors = {grade.grade: grade.color for grade in grades}
    return jsonify(grade_colors)

# User Profile Routes
@app.route('/api/user/ticks', methods=['GET'])
@jwt_required()
def get_user_ticks():
    """Get all ticks for the current user with route details"""
    user_id = get_current_user_id()
    
    # Join ticks with routes and grades to get route details using explicit joins
    ticks_with_routes = db.session.query(Tick, Route, Grade)\
        .join(Route, Tick.route_id == Route.id)\
        .join(Grade, Route.grade_id == Grade.id)\
        .filter(Tick.user_id == user_id)\
        .order_by(Tick.created_at.desc()).all()
    
    result = []
    for tick, route, grade in ticks_with_routes:
        tick_data = tick.to_dict()
        tick_data['route_name'] = route.name
        tick_data['route_grade'] = grade.grade
        tick_data['wall_section'] = route.wall_section
        result.append(tick_data)
    
    return jsonify(result)

@app.route('/api/user/likes', methods=['GET'])
@jwt_required()
def get_user_likes():
    """Get all likes for the current user with route details"""
    user_id = get_current_user_id()
    
    # Join likes with routes and grades to get route details using explicit joins
    likes_with_routes = db.session.query(Like, Route, Grade)\
        .join(Route, Like.route_id == Route.id)\
        .join(Grade, Route.grade_id == Grade.id)\
        .filter(Like.user_id == user_id)\
        .order_by(Like.created_at.desc()).all()
    
    result = []
    for like, route, grade in likes_with_routes:
        like_data = like.to_dict()
        like_data['route_name'] = route.name
        like_data['route_grade'] = grade.grade
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
    projects = Project.query.filter_by(user_id=user_id).all()
    
    # Calculate basic statistics
    total_ticks = len(ticks)
    total_likes = len(likes)
    total_comments = len(comments)
    total_attempts = sum(tick.attempts or 0 for tick in ticks)
    average_attempts = total_attempts / total_ticks if total_ticks > 0 else 0
    
    # Calculate send statistics
    top_rope_sends = sum(1 for tick in ticks if tick.top_rope_send)
    lead_sends = sum(1 for tick in ticks if tick.lead_send)
    total_sends = len([tick for tick in ticks if tick.has_any_send])
    
    # Calculate flash statistics
    top_rope_flashes = sum(1 for tick in ticks if tick.top_rope_flash)
    lead_flashes = sum(1 for tick in ticks if tick.lead_flash)
    total_flashes = sum(1 for tick in ticks if tick.has_any_flash)
    legacy_flashes = sum(1 for tick in ticks if tick.flash)  # For backward compatibility
    
    # Get sent routes for grade analysis
    sent_route_ids = [tick.route_id for tick in ticks if tick.has_any_send]
    top_rope_route_ids = [tick.route_id for tick in ticks if tick.top_rope_send]
    lead_route_ids = [tick.route_id for tick in ticks if tick.lead_send]
    
    # Get achieved grades
    achieved_grades = []
    hardest_grade = None
    hardest_top_rope_grade = None
    hardest_lead_grade = None
    
    if sent_route_ids:
        sent_routes = Route.query.filter(Route.id.in_(sent_route_ids)).all()
        achieved_grade_objects = [route.grade_rel for route in sent_routes if route.grade_rel]
        if achieved_grade_objects:
            # Remove duplicates and sort
            unique_grades = list(set(achieved_grade_objects))
            unique_grades.sort(key=lambda g: g.difficulty_order)
            achieved_grades = [grade.grade for grade in unique_grades]
            hardest_grade = max(unique_grades, key=lambda g: g.difficulty_order).grade
    
    if top_rope_route_ids:
        tr_routes = Route.query.filter(Route.id.in_(top_rope_route_ids)).all()
        tr_grades = [route.grade_rel for route in tr_routes if route.grade_rel]
        if tr_grades:
            hardest_top_rope_grade = max(tr_grades, key=lambda g: g.difficulty_order).grade
    
    if lead_route_ids:
        lead_routes = Route.query.filter(Route.id.in_(lead_route_ids)).all()
        lead_grades = [route.grade_rel for route in lead_routes if route.grade_rel]
        if lead_grades:
            hardest_lead_grade = max(lead_grades, key=lambda g: g.difficulty_order).grade
    
    # Get unique wall sections from sent routes
    unique_wall_sections = 0
    if sent_route_ids:
        sent_routes = Route.query.filter(Route.id.in_(sent_route_ids)).all()
        unique_wall_sections = len(set(route.wall_section for route in sent_routes))
    
    return jsonify({
        # Basic stats
        'total_ticks': total_ticks,
        'total_likes': total_likes,
        'total_comments': total_comments,
        'total_attempts': total_attempts,
        'average_attempts': round(average_attempts, 2),
        'total_projects': len(projects),
        
        # Send stats
        'total_sends': total_sends,
        'top_rope_sends': top_rope_sends,
        'lead_sends': lead_sends,
        
        # Flash stats
        'total_flashes': total_flashes,
        'top_rope_flashes': top_rope_flashes,
        'lead_flashes': lead_flashes,
        'legacy_flashes': legacy_flashes,  # For backward compatibility
        
        # Grade achievements
        'hardest_grade': hardest_grade,
        'hardest_top_rope_grade': hardest_top_rope_grade,
        'hardest_lead_grade': hardest_lead_grade,
        'achieved_grades': achieved_grades,
        
        # Other stats
        'unique_wall_sections': unique_wall_sections
    })

# Simple database initialization check
def ensure_database_initialized():
    """Ensure database is initialized, create tables if they don't exist"""
    db.create_all()
    
    # Check if we have essential data
    if not Grade.query.first() or not HoldColor.query.first():
        print("⚠️  Database appears to be empty!")
        print("Please run 'python init_db.py' to initialize the database with grades, colors, and sample data.")
        return False
    
    return True

@app.route('/api/user/nickname', methods=['PUT'])
@jwt_required()
def update_nickname():
    """Update current user's public nickname"""
    user_id = get_current_user_id()
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    data = request.get_json() or {}
    nickname = data.get('nickname', '').strip()

    if not nickname:
        return jsonify({'error': 'Nickname is required'}), 400
    if not (3 <= len(nickname) <= 20):
        return jsonify({'error': 'Nickname must be between 3 and 20 characters'}), 400
    import re
    if not re.match(r'^[A-Za-z0-9_]+$', nickname):
        return jsonify({'error': 'Nickname can contain only letters, numbers, and underscores'}), 400

    # Uniqueness excluding self (case-insensitive)
    exists = db.session.query(User.id).filter(
        func.lower(User.nickname) == nickname.lower(),
        User.id != user.id
    ).first()
    if exists:
        return jsonify({'error': 'Nickname already taken'}), 400

    user.nickname = nickname
    db.session.commit()

    return jsonify({'message': 'Nickname updated', 'user': user.to_dict()}), 200

if __name__ == '__main__':
    with app.app_context():
        ensure_database_initialized()
    app.run(debug=True, host='0.0.0.0', port=5000)
