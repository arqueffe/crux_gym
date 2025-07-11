from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# Database configuration
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{os.path.join(basedir, "climbing_gym.db")}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Models
class Route(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    grade = db.Column(db.String(10), nullable=False)
    route_setter = db.Column(db.String(100), nullable=False)
    wall_section = db.Column(db.String(50), nullable=False)
    color = db.Column(db.String(20), nullable=True)
    description = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    likes = db.relationship('Like', backref='route', lazy=True, cascade='all, delete-orphan')
    comments = db.relationship('Comment', backref='route', lazy=True, cascade='all, delete-orphan')
    grade_proposals = db.relationship('GradeProposal', backref='route', lazy=True, cascade='all, delete-orphan')
    warnings = db.relationship('Warning', backref='route', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'grade': self.grade,
            'route_setter': self.route_setter,
            'wall_section': self.wall_section,
            'color': self.color,
            'description': self.description,
            'created_at': self.created_at.isoformat(),
            'likes_count': len(self.likes),
            'comments_count': len(self.comments),
            'grade_proposals_count': len(self.grade_proposals),
            'warnings_count': len(self.warnings)
        }

class Like(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_name': self.user_name,
            'route_id': self.route_id,
            'created_at': self.created_at.isoformat()
        }

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    content = db.Column(db.Text, nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_name': self.user_name,
            'content': self.content,
            'route_id': self.route_id,
            'created_at': self.created_at.isoformat()
        }

class GradeProposal(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    proposed_grade = db.Column(db.String(10), nullable=False)
    reasoning = db.Column(db.Text, nullable=True)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_name': self.user_name,
            'proposed_grade': self.proposed_grade,
            'reasoning': self.reasoning,
            'route_id': self.route_id,
            'created_at': self.created_at.isoformat()
        }

class Warning(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    warning_type = db.Column(db.String(50), nullable=False)  # e.g., 'broken_hold', 'safety_issue', 'needs_cleaning'
    description = db.Column(db.Text, nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.id'), nullable=False)
    status = db.Column(db.String(20), default='open')  # 'open', 'acknowledged', 'resolved'
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_name': self.user_name,
            'warning_type': self.warning_type,
            'description': self.description,
            'route_id': self.route_id,
            'status': self.status,
            'created_at': self.created_at.isoformat()
        }

# API Routes

@app.route('/api/routes', methods=['GET'])
def get_routes():
    """Get all routes with optional filtering"""
    wall_section = request.args.get('wall_section')
    grade = request.args.get('grade')
    
    query = Route.query
    if wall_section:
        query = query.filter(Route.wall_section == wall_section)
    if grade:
        query = query.filter(Route.grade == grade)
    
    routes = query.all()
    return jsonify([route.to_dict() for route in routes])

@app.route('/api/routes/<int:route_id>', methods=['GET'])
def get_route(route_id):
    """Get a specific route with all details"""
    route = Route.query.get_or_404(route_id)
    route_data = route.to_dict()
    
    # Add detailed information
    route_data['likes'] = [like.to_dict() for like in route.likes]
    route_data['comments'] = [comment.to_dict() for comment in route.comments]
    route_data['grade_proposals'] = [proposal.to_dict() for proposal in route.grade_proposals]
    route_data['warnings'] = [warning.to_dict() for warning in route.warnings]
    
    return jsonify(route_data)

@app.route('/api/routes', methods=['POST'])
def create_route():
    """Create a new route"""
    data = request.get_json()
    
    route = Route(
        name=data['name'],
        grade=data['grade'],
        route_setter=data['route_setter'],
        wall_section=data['wall_section'],
        color=data.get('color'),
        description=data.get('description')
    )
    
    db.session.add(route)
    db.session.commit()
    
    return jsonify(route.to_dict()), 201

@app.route('/api/routes/<int:route_id>/like', methods=['POST'])
def like_route(route_id):
    """Like a route"""
    data = request.get_json()
    user_name = data['user_name']
    
    # Check if user already liked this route
    existing_like = Like.query.filter_by(route_id=route_id, user_name=user_name).first()
    if existing_like:
        return jsonify({'message': 'Already liked'}), 400
    
    like = Like(route_id=route_id, user_name=user_name)
    db.session.add(like)
    db.session.commit()
    
    return jsonify(like.to_dict()), 201

@app.route('/api/routes/<int:route_id>/unlike', methods=['DELETE'])
def unlike_route(route_id):
    """Unlike a route"""
    data = request.get_json()
    user_name = data['user_name']
    
    like = Like.query.filter_by(route_id=route_id, user_name=user_name).first()
    if not like:
        return jsonify({'message': 'Like not found'}), 404
    
    db.session.delete(like)
    db.session.commit()
    
    return jsonify({'message': 'Unliked successfully'}), 200

@app.route('/api/routes/<int:route_id>/comments', methods=['POST'])
def add_comment(route_id):
    """Add a comment to a route"""
    data = request.get_json()
    
    comment = Comment(
        route_id=route_id,
        user_name=data['user_name'],
        content=data['content']
    )
    
    db.session.add(comment)
    db.session.commit()
    
    return jsonify(comment.to_dict()), 201

@app.route('/api/routes/<int:route_id>/grade-proposals', methods=['POST'])
def propose_grade(route_id):
    """Propose a different grade for a route"""
    data = request.get_json()
    
    proposal = GradeProposal(
        route_id=route_id,
        user_name=data['user_name'],
        proposed_grade=data['proposed_grade'],
        reasoning=data.get('reasoning')
    )
    
    db.session.add(proposal)
    db.session.commit()
    
    return jsonify(proposal.to_dict()), 201

@app.route('/api/routes/<int:route_id>/warnings', methods=['POST'])
def add_warning(route_id):
    """Add a warning for a route"""
    data = request.get_json()
    
    warning = Warning(
        route_id=route_id,
        user_name=data['user_name'],
        warning_type=data['warning_type'],
        description=data['description']
    )
    
    db.session.add(warning)
    db.session.commit()
    
    return jsonify(warning.to_dict()), 201

@app.route('/api/wall-sections', methods=['GET'])
def get_wall_sections():
    """Get all unique wall sections"""
    sections = db.session.query(Route.wall_section).distinct().all()
    return jsonify([section[0] for section in sections])

@app.route('/api/grades', methods=['GET'])
def get_grades():
    """Get all unique grades"""
    grades = db.session.query(Route.grade).distinct().all()
    return jsonify([grade[0] for grade in grades])

# Initialize database
def init_db():
    """Initialize database with sample data"""
    db.create_all()
    
    # Check if we already have data
    if Route.query.first():
        return
    
    # Sample routes
    sample_routes = [
        Route(name="Crimpy Goodness", grade="V4", route_setter="Alice Johnson", wall_section="Overhang Wall", color="Red", description="Technical crimps with a dynamic finish"),
        Route(name="Slab Master", grade="V2", route_setter="Bob Smith", wall_section="Slab Wall", color="Blue", description="Balance and footwork focused"),
        Route(name="Power House", grade="V6", route_setter="Charlie Brown", wall_section="Steep Wall", color="Yellow", description="Raw power moves with big holds"),
        Route(name="Finger Torture", grade="V5", route_setter="Diana Prince", wall_section="Overhang Wall", color="Green", description="Tiny crimps and pinches"),
        Route(name="Beginner's Delight", grade="V1", route_setter="Eve Wilson", wall_section="Vertical Wall", color="Orange", description="Perfect for new climbers"),
        Route(name="The Gaston", grade="V3", route_setter="Frank Miller", wall_section="Vertical Wall", color="Purple", description="Lots of gaston moves"),
    ]
    
    for route in sample_routes:
        db.session.add(route)
    
    db.session.commit()
    print("Database initialized with sample data!")

if __name__ == '__main__':
    with app.app_context():
        init_db()
    app.run(debug=True, host='0.0.0.0', port=5000)
