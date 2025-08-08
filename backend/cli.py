#!/usr/bin/env python3
"""
Crux Backend CLI - Simple command line tool to manage the database.

Usage examples:
  # Users
  python cli.py users add --username john --nickname Johnny --email john@example.com --password secret123
  python cli.py users list
  python cli.py users set-password --username john --password newpass
  python cli.py users set-nickname --username john --nickname J_Doe
  python cli.py users activate --username john
  python cli.py users deactivate --username john
  python cli.py users delete --username john

  # Routes
  python cli.py routes add --name "New Route" --grade 6a+ --setter "John Doe" --wall "Steep Wall" --lane 3 --color Red --description "Fun route"
  python cli.py routes list --grade 6a+
  python cli.py routes update --id 5 --name "Renamed" --grade 6b --lane 4 --color Blue
  python cli.py routes delete --id 5

  # Reference data
  python cli.py grades list
  python cli.py colors list

  # Database helpers
  python cli.py db init
  python cli.py db migrate-nickname
  python cli.py db create-tables
"""
import os
import sys
import argparse
from typing import Optional

# Ensure we can import the Flask app
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE_DIR)

from app import app, db, User, Route, Grade, HoldColor  # noqa: E402

# Optional imports for helpers
try:
    import init_db as init_db_module  # noqa: E402
except Exception:
    init_db_module = None

try:
    import migrate_add_nickname as migrate_nickname_module  # noqa: E402
except Exception:
    migrate_nickname_module = None


def print_header(title: str):
    print("=" * 80)
    print(title)
    print("=" * 80)


# =====================
# User commands
# =====================

def users_add(args):
    with app.app_context():
        if User.query.filter_by(username=args.username).first():
            print(f"Error: username '{args.username}' already exists")
            return 1
        if User.query.filter_by(email=args.email).first():
            print(f"Error: email '{args.email}' already exists")
            return 1
        # Case-insensitive nickname uniqueness
        from sqlalchemy import func
        if db.session.query(User.id).filter(func.lower(User.nickname) == args.nickname.lower()).first():
            print(f"Error: nickname '{args.nickname}' already taken")
            return 1

        user = User(username=args.username, nickname=args.nickname, email=args.email)
        user.set_password(args.password)
        db.session.add(user)
        db.session.commit()
        print(f"✓ Created user id={user.id}, username={user.username}, nickname={user.nickname}")
        return 0


def users_list(_args):
    with app.app_context():
        print_header("Users")
        users = User.query.order_by(User.created_at.desc()).all()
        for u in users:
            print(f"[{u.id}] username={u.username} nickname={u.nickname} email={u.email} active={u.is_active}")
        print(f"Total: {len(users)}")
        return 0


def users_set_password(args):
    with app.app_context():
        user = User.query.filter_by(username=args.username).first()
        if not user:
            print(f"Error: user '{args.username}' not found")
            return 1
        user.set_password(args.password)
        db.session.commit()
        print("✓ Password updated")
        return 0


def users_set_nickname(args):
    with app.app_context():
        user = User.query.filter_by(username=args.username).first()
        if not user:
            print(f"Error: user '{args.username}' not found")
            return 1
        nickname = args.nickname.strip()
        if not (3 <= len(nickname) <= 20):
            print("Error: nickname must be 3-20 characters")
            return 1
        import re
        if not re.match(r'^[A-Za-z0-9_]+$', nickname):
            print("Error: nickname can contain only letters, numbers, and underscores")
            return 1
        from sqlalchemy import func
        exists = db.session.query(User.id).filter(func.lower(User.nickname) == nickname.lower(), User.id != user.id).first()
        if exists:
            print(f"Error: nickname '{nickname}' already taken")
            return 1
        user.nickname = nickname
        db.session.commit()
        print("✓ Nickname updated")
        return 0


def users_set_active(args, active: bool):
    with app.app_context():
        user = User.query.filter_by(username=args.username).first()
        if not user:
            print(f"Error: user '{args.username}' not found")
            return 1
        user.is_active = active
        db.session.commit()
        print(f"✓ User {'activated' if active else 'deactivated'}")
        return 0


def users_delete(args):
    with app.app_context():
        user = User.query.filter_by(username=args.username).first()
        if not user:
            print(f"Error: user '{args.username}' not found")
            return 1
        # Simple safety: prevent delete if has related records (likes, comments, ticks, etc.)
        has_related = any([
            getattr(user, 'likes', None),
            getattr(user, 'comments', None),
            getattr(user, 'grade_proposals', None),
            getattr(user, 'warnings', None),
            getattr(user, 'ticks', None),
            getattr(user, 'projects', None),
        ])
        if has_related and not args.force:
            print("Error: user has related records (likes/comments/ticks/etc.). Use --force to delete after manual cleanup.")
            return 1
        try:
            db.session.delete(user)
            db.session.commit()
            print("✓ User deleted")
            return 0
        except Exception as e:
            db.session.rollback()
            print(f"Error: failed to delete user: {e}")
            return 1


# =====================
# Route commands
# =====================

def _get_grade_by_code(code: str) -> Optional[Grade]:
    return Grade.query.filter_by(grade=code).first()


def _get_color_by_name(name: Optional[str]) -> Optional[HoldColor]:
    if not name:
        return None
    return HoldColor.query.filter_by(name=name).first()


def routes_add(args):
    with app.app_context():
        grade = _get_grade_by_code(args.grade)
        if not grade:
            available = ", ".join(g.grade for g in Grade.query.order_by(Grade.difficulty_order).all())
            print(f"Error: invalid grade '{args.grade}'. Available: {available}")
            return 1
        color = _get_color_by_name(args.color)
        if args.color and not color:
            available = ", ".join(c.name for c in HoldColor.query.order_by(HoldColor.name).all())
            print(f"Error: invalid color '{args.color}'. Available: {available}")
            return 1
        try:
            route = Route(
                name=args.name,
                grade_id=grade.id,
                route_setter=args.setter,
                wall_section=args.wall,
                lane=args.lane,
                hold_color_id=color.id if color else None,
                description=args.description,
            )
            db.session.add(route)
            db.session.commit()
            print(f"✓ Created route id={route.id} name='{route.name}' grade={args.grade} lane={args.lane}")
            return 0
        except Exception as e:
            db.session.rollback()
            print(f"Error: failed to create route: {e}")
            return 1


def routes_list(args):
    with app.app_context():
        from sqlalchemy import and_
        q = db.session.query(Route).join(Grade, Route.grade_id == Grade.id)
        filters = []
        if args.wall:
            filters.append(Route.wall_section == args.wall)
        if args.grade:
            filters.append(Grade.grade == args.grade)
        if args.lane is not None:
            filters.append(Route.lane == args.lane)
        if filters:
            q = q.filter(and_(*filters))
        routes = q.order_by(Route.created_at.desc()).all()
        print_header("Routes")
        for r in routes:
            print(f"[{r.id}] {r.name} | grade={r.grade_rel.grade if r.grade_rel else '?'} | wall='{r.wall_section}' | lane={r.lane} | color={r.hold_color_rel.name if r.hold_color_rel else '-'}")
        print(f"Total: {len(routes)}")
        return 0


def routes_update(args):
    with app.app_context():
        route = Route.query.get(args.id)
        if not route:
            print(f"Error: route id={args.id} not found")
            return 1
        # Name
        if args.name is not None:
            route.name = args.name
        # Grade
        if args.grade is not None:
            g = _get_grade_by_code(args.grade)
            if not g:
                available = ", ".join(x.grade for x in Grade.query.order_by(Grade.difficulty_order).all())
                print(f"Error: invalid grade '{args.grade}'. Available: {available}")
                return 1
            route.grade_id = g.id
        # Setter
        if args.setter is not None:
            route.route_setter = args.setter
        # Wall
        if args.wall is not None:
            route.wall_section = args.wall
        # Lane
        if args.lane is not None:
            route.lane = args.lane
        # Color
        if args.color is not None:
            color = _get_color_by_name(args.color)
            if args.color and not color:
                available = ", ".join(c.name for c in HoldColor.query.order_by(HoldColor.name).all())
                print(f"Error: invalid color '{args.color}'. Available: {available}")
                return 1
            route.hold_color_id = color.id if color else None
        # Description
        if args.description is not None:
            route.description = args.description

        try:
            db.session.commit()
            print("✓ Route updated")
            return 0
        except Exception as e:
            db.session.rollback()
            print(f"Error: failed to update route: {e}")
            return 1


def routes_delete(args):
    with app.app_context():
        route = Route.query.get(args.id)
        if not route:
            print(f"Error: route id={args.id} not found")
            return 1
        try:
            db.session.delete(route)
            db.session.commit()
            print("✓ Route deleted")
            return 0
        except Exception as e:
            db.session.rollback()
            print(f"Error: failed to delete route: {e}")
            return 1


# =====================
# Reference data commands
# =====================

def grades_list(_args):
    with app.app_context():
        print_header("Grades")
        grades = Grade.query.order_by(Grade.difficulty_order).all()
        for g in grades:
            print(f"{g.grade}\torder={g.difficulty_order}\tcolor={g.color}")
        print(f"Total: {len(grades)}")
        return 0


def colors_list(_args):
    with app.app_context():
        print_header("Hold Colors")
        colors = HoldColor.query.order_by(HoldColor.name).all()
        for c in colors:
            print(f"{c.id}\t{c.name}\t{c.hex_code}")
        print(f"Total: {len(colors)}")
        return 0


# =====================
# DB helpers
# =====================

def db_init(_args):
    if not init_db_module:
        print("Error: init_db module not found")
        return 1
    with app.app_context():
        init_db_module.init_database()
        return 0


def db_migrate_nickname(_args):
    if not migrate_nickname_module:
        print("Error: migrate_add_nickname module not found")
        return 1
    migrate_nickname_module.main()
    return 0


def db_create_tables(_args):
    with app.app_context():
        db.create_all()
        print("✓ Tables ensured (create_all)")
        return 0


# =====================
# Argument parser setup
# =====================

def build_parser():
    parser = argparse.ArgumentParser(description="Crux Backend CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # users
    users = subparsers.add_parser("users", help="Manage users")
    users_sub = users.add_subparsers(dest="action", required=True)

    u_add = users_sub.add_parser("add", help="Add a user")
    u_add.add_argument("--username", required=True)
    u_add.add_argument("--nickname", required=True)
    u_add.add_argument("--email", required=True)
    u_add.add_argument("--password", required=True)
    u_add.set_defaults(func=users_add)

    u_list = users_sub.add_parser("list", help="List users")
    u_list.set_defaults(func=users_list)

    u_pw = users_sub.add_parser("set-password", help="Change a user's password")
    u_pw.add_argument("--username", required=True)
    u_pw.add_argument("--password", required=True)
    u_pw.set_defaults(func=users_set_password)

    u_nn = users_sub.add_parser("set-nickname", help="Change a user's nickname")
    u_nn.add_argument("--username", required=True)
    u_nn.add_argument("--nickname", required=True)
    u_nn.set_defaults(func=users_set_nickname)

    u_act = users_sub.add_parser("activate", help="Activate a user account")
    u_act.add_argument("--username", required=True)
    u_act.set_defaults(func=lambda a: users_set_active(a, True))

    u_deact = users_sub.add_parser("deactivate", help="Deactivate a user account")
    u_deact.add_argument("--username", required=True)
    u_deact.set_defaults(func=lambda a: users_set_active(a, False))

    u_del = users_sub.add_parser("delete", help="Delete a user")
    u_del.add_argument("--username", required=True)
    u_del.add_argument("--force", action="store_true", help="Attempt delete even if related records exist")
    u_del.set_defaults(func=users_delete)

    # routes
    routes = subparsers.add_parser("routes", help="Manage routes")
    routes_sub = routes.add_subparsers(dest="action", required=True)

    r_add = routes_sub.add_parser("add", help="Add a route")
    r_add.add_argument("--name", required=True)
    r_add.add_argument("--grade", required=True, help="Grade code, e.g. 6a+")
    r_add.add_argument("--setter", required=True, help="Route setter")
    r_add.add_argument("--wall", required=True, help="Wall section")
    r_add.add_argument("--lane", required=True, type=int)
    r_add.add_argument("--color", required=False, help="Hold color name")
    r_add.add_argument("--description", required=False, default=None)
    r_add.set_defaults(func=routes_add)

    r_list = routes_sub.add_parser("list", help="List routes")
    r_list.add_argument("--wall", required=False)
    r_list.add_argument("--grade", required=False)
    r_list.add_argument("--lane", required=False, type=int)
    r_list.set_defaults(func=routes_list)

    r_upd = routes_sub.add_parser("update", help="Update a route by id (only provided fields will be changed)")
    r_upd.add_argument("--id", required=True, type=int)
    r_upd.add_argument("--name")
    r_upd.add_argument("--grade")
    r_upd.add_argument("--setter")
    r_upd.add_argument("--wall")
    r_upd.add_argument("--lane", type=int)
    r_upd.add_argument("--color")
    r_upd.add_argument("--description")
    r_upd.set_defaults(func=routes_update)

    r_del = routes_sub.add_parser("delete", help="Delete a route")
    r_del.add_argument("--id", required=True, type=int)
    r_del.set_defaults(func=routes_delete)

    # grades
    grades = subparsers.add_parser("grades", help="Reference: grades")
    grades_sub = grades.add_subparsers(dest="action", required=True)
    g_list = grades_sub.add_parser("list", help="List grades")
    g_list.set_defaults(func=grades_list)

    # colors
    colors = subparsers.add_parser("colors", help="Reference: hold colors")
    colors_sub = colors.add_subparsers(dest="action", required=True)
    c_list = colors_sub.add_parser("list", help="List hold colors")
    c_list.set_defaults(func=colors_list)

    # db helpers
    dbp = subparsers.add_parser("db", help="Database utilities")
    db_sub = dbp.add_subparsers(dest="action", required=True)

    d_init = db_sub.add_parser("init", help="Initialize database with seed data")
    d_init.set_defaults(func=db_init)

    d_mig = db_sub.add_parser("migrate-nickname", help="Add/backfill nickname column")
    d_mig.set_defaults(func=db_migrate_nickname)

    d_create = db_sub.add_parser("create-tables", help="Run db.create_all()")
    d_create.set_defaults(func=db_create_tables)

    return parser


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)
    func = getattr(args, 'func', None)
    if not func:
        parser.print_help()
        return 2
    return func(args)


if __name__ == '__main__':
    raise SystemExit(main())
