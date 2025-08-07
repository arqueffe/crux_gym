#!/usr/bin/env python3
"""
Database initialization script for Crux Climbing Gym API
This script initializes the database with grades, hold colors, and sample data.
"""

import os
import sys
from datetime import datetime

# Add the current directory to the path so we can import app
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db, User, Route, Grade, HoldColor, Like, Comment, GradeProposal, Warning, Tick

# French Climbing Grades with difficulty ordering and colors
FRENCH_GRADES_DATA = [
    # Grade 3 - Light Green
    {'grade': '3a', 'difficulty_order': 10, 'color': '#90EE90'},
    {'grade': '3b', 'difficulty_order': 11, 'color': '#90EE90'},
    {'grade': '3c', 'difficulty_order': 12, 'color': '#90EE90'},
    
    # Grade 4 - Pale Green
    {'grade': '4a', 'difficulty_order': 20, 'color': '#98FB98'},
    {'grade': '4b', 'difficulty_order': 21, 'color': '#98FB98'},
    {'grade': '4c', 'difficulty_order': 22, 'color': '#98FB98'},
    
    # Grade 5 - Yellow
    {'grade': '5a', 'difficulty_order': 30, 'color': '#FFFF00'},
    {'grade': '5b', 'difficulty_order': 31, 'color': '#FFFF00'},
    {'grade': '5c', 'difficulty_order': 32, 'color': '#FFFF00'},
    
    # Grade 6 - Gold to Orange
    {'grade': '6a', 'difficulty_order': 40, 'color': '#FFD700'},
    {'grade': '6a+', 'difficulty_order': 41, 'color': '#FFD700'},
    {'grade': '6b', 'difficulty_order': 42, 'color': '#FFA500'},
    {'grade': '6b+', 'difficulty_order': 43, 'color': '#FFA500'},
    {'grade': '6c', 'difficulty_order': 44, 'color': '#FF8C00'},
    {'grade': '6c+', 'difficulty_order': 45, 'color': '#FF8C00'},
    
    # Grade 7 - Red spectrum
    {'grade': '7a', 'difficulty_order': 50, 'color': '#FF6347'},
    {'grade': '7a+', 'difficulty_order': 51, 'color': '#FF6347'},
    {'grade': '7b', 'difficulty_order': 52, 'color': '#FF4500'},
    {'grade': '7b+', 'difficulty_order': 53, 'color': '#FF4500'},
    {'grade': '7c', 'difficulty_order': 54, 'color': '#FF0000'},
    {'grade': '7c+', 'difficulty_order': 55, 'color': '#FF0000'},
    
    # Grade 8 - Dark Red to Purple
    {'grade': '8a', 'difficulty_order': 60, 'color': '#8B0000'},
    {'grade': '8a+', 'difficulty_order': 61, 'color': '#8B0000'},
    {'grade': '8b', 'difficulty_order': 62, 'color': '#800080'},
    {'grade': '8b+', 'difficulty_order': 63, 'color': '#800080'},
    {'grade': '8c', 'difficulty_order': 64, 'color': '#4B0082'},
    {'grade': '8c+', 'difficulty_order': 65, 'color': '#4B0082'},
    
    # Grade 9 - Navy to Black
    {'grade': '9a', 'difficulty_order': 70, 'color': '#000080'},
    {'grade': '9a+', 'difficulty_order': 71, 'color': '#000080'},
    {'grade': '9b', 'difficulty_order': 72, 'color': '#000000'},
    {'grade': '9b+', 'difficulty_order': 73, 'color': '#000000'},
    {'grade': '9c', 'difficulty_order': 74, 'color': '#000000'},
]

# Hold Colors Data
HOLD_COLORS_DATA = [
    {'name': 'Red', 'hex_code': '#FF0000'},
    {'name': 'Blue', 'hex_code': '#0000FF'},
    {'name': 'Green', 'hex_code': '#008000'},
    {'name': 'Yellow', 'hex_code': '#FFFF00'},
    {'name': 'Orange', 'hex_code': '#FFA500'},
    {'name': 'Purple', 'hex_code': '#800080'},
    {'name': 'Pink', 'hex_code': '#FFC0CB'},
    {'name': 'Black', 'hex_code': '#000000'},
    {'name': 'White', 'hex_code': '#FFFFFF'},
    {'name': 'Gray', 'hex_code': '#808080'},
    {'name': 'Brown', 'hex_code': '#A52A2A'},
    {'name': 'Lime', 'hex_code': '#00FF00'},
    {'name': 'Cyan', 'hex_code': '#00FFFF'},
    {'name': 'Magenta', 'hex_code': '#FF00FF'},
    {'name': 'Maroon', 'hex_code': '#800000'},
    {'name': 'Navy', 'hex_code': '#000080'},
    {'name': 'Olive', 'hex_code': '#808000'},
    {'name': 'Teal', 'hex_code': '#008080'},
]

def init_grades():
    """Initialize grades in the database"""
    print("Initializing grades...")
    
    for grade_data in FRENCH_GRADES_DATA:
        existing_grade = Grade.query.filter_by(grade=grade_data['grade']).first()
        if not existing_grade:
            grade = Grade(
                grade=grade_data['grade'],
                difficulty_order=grade_data['difficulty_order'],
                color=grade_data['color']
            )
            db.session.add(grade)
    
    db.session.commit()
    print(f"✓ Initialized {len(FRENCH_GRADES_DATA)} grades")

def init_hold_colors():
    """Initialize hold colors in the database"""
    print("Initializing hold colors...")
    
    for color_data in HOLD_COLORS_DATA:
        existing_color = HoldColor.query.filter_by(name=color_data['name']).first()
        if not existing_color:
            hold_color = HoldColor(
                name=color_data['name'],
                hex_code=color_data['hex_code']
            )
            db.session.add(hold_color)
    
    db.session.commit()
    print(f"✓ Initialized {len(HOLD_COLORS_DATA)} hold colors")

def init_sample_users():
    """Initialize sample users"""
    print("Initializing sample users...")
    
    # Check if we already have users
    if User.query.first():
        print("✓ Users already exist, skipping...")
        return
    
    # Create sample users
    users_data = [
        {'username': 'admin', 'email': 'admin@climbing-gym.com', 'password': 'admin123'},
        {'username': 'alice_johnson', 'email': 'alice@example.com', 'password': 'password123'},
        {'username': 'bob_smith', 'email': 'bob@example.com', 'password': 'password123'},
        {'username': 'charlie_brown', 'email': 'charlie@example.com', 'password': 'password123'},
    ]
    
    for user_data in users_data:
        user = User(username=user_data['username'], email=user_data['email'])
        user.set_password(user_data['password'])
        db.session.add(user)
    
    db.session.commit()
    print(f"✓ Initialized {len(users_data)} sample users")

def init_sample_routes():
    """Initialize sample routes"""
    print("Initializing sample routes...")
    
    # Check if we already have routes
    if Route.query.first():
        print("✓ Routes already exist, skipping...")
        return
    
    # Get grades and colors from database
    grades = {g.grade: g for g in Grade.query.all()}
    hold_colors = {c.name: c for c in HoldColor.query.all()}
    
    sample_routes_data = [
        {
            'name': "Crimpy Goodness",
            'grade': "6b", 
            'route_setter': "Alice Johnson",
            'wall_section': "Overhang Wall",
            'lane': 1,
            'color': "Red",
            'description': "Technical crimps with a dynamic finish"
        },
        {
            'name': "Slab Master",
            'grade': "5b",
            'route_setter': "Bob Smith",
            'wall_section': "Slab Wall",
            'lane': 3,
            'color': "Blue",
            'description': "Balance and footwork focused"
        },
        {
            'name': "Power House",
            'grade': "7a+",
            'route_setter': "Charlie Brown",
            'wall_section': "Steep Wall",
            'lane': 2,
            'color': "Yellow",
            'description': "Raw power moves with big holds"
        },
        {
            'name': "Finger Torture",
            'grade': "6c+",
            'route_setter': "Diana Prince",
            'wall_section': "Overhang Wall",
            'lane': 4,
            'color': "Green",
            'description': "Tiny crimps and pinches"
        },
        {
            'name': "Beginner's Delight",
            'grade': "4b",
            'route_setter': "Eve Wilson",
            'wall_section': "Vertical Wall",
            'lane': 1,
            'color': "Orange",
            'description': "Perfect for new climbers"
        },
        {
            'name': "The Gaston",
            'grade': "5c",
            'route_setter': "Frank Miller",
            'wall_section': "Vertical Wall",
            'lane': 2,
            'color': "Purple",
            'description': "Lots of gaston moves"
        },
        {
            'name': "Roof Crusher",
            'grade': "7b",
            'route_setter': "Grace Lee",
            'wall_section': "Roof Section",
            'lane': 1,
            'color': "Black",
            'description': "Powerful roof climbing with heel hooks"
        },
        {
            'name': "Balance Beam",
            'grade': "4c",
            'route_setter': "Henry Chen",
            'wall_section': "Slab Wall",
            'lane': 2,
            'color': "White",
            'description': "Pure balance and technique"
        },
        {
            'name': "Pocket Rocket",
            'grade': "6a+",
            'route_setter': "Ivy Rodriguez",
            'wall_section': "Steep Wall",
            'lane': 3,
            'color': "Pink",
            'description': "Tricky pocket sequences"
        },
        {
            'name': "The Mantle",
            'grade': "5a",
            'route_setter': "Jack Thompson",
            'wall_section': "Vertical Wall",
            'lane': 4,
            'color': "Gray",
            'description': "Classic mantle finish"
        },
    ]
    
    for route_data in sample_routes_data:
        grade = grades.get(route_data['grade'])
        hold_color = hold_colors.get(route_data['color'])
        
        if grade:  # Only create route if grade exists
            route = Route(
                name=route_data['name'],
                grade_id=grade.id,
                route_setter=route_data['route_setter'],
                wall_section=route_data['wall_section'],
                lane=route_data['lane'],
                hold_color_id=hold_color.id if hold_color else None,
                description=route_data['description']
            )
            db.session.add(route)
    
    db.session.commit()
    print(f"✓ Initialized {len(sample_routes_data)} sample routes")

def init_database():
    """Initialize the complete database"""
    print("🏔️  Initializing Crux Climbing Gym Database...")
    print("=" * 50)
    
    # Create all tables
    print("Creating database tables...")
    db.create_all()
    print("✓ Database tables created")
    
    # Initialize data in order
    init_grades()
    init_hold_colors()
    init_sample_users()
    init_sample_routes()
    
    print("=" * 50)
    print("🎉 Database initialization complete!")
    print("\nSample user accounts created:")
    print("- admin / admin123")
    print("- alice_johnson / password123")
    print("- bob_smith / password123")
    print("- charlie_brown / password123")
    print(f"\nDatabase file: {app.config['SQLALCHEMY_DATABASE_URI']}")

if __name__ == '__main__':
    with app.app_context():
        init_database()
