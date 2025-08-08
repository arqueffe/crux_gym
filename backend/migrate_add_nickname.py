#!/usr/bin/env python3
"""
Migration script to add the `nickname` column to the users table and backfill values.

Usage:
    python migrate_add_nickname.py

This will:
  - Add a new TEXT column `nickname` to the `user` table if it does not exist
  - Backfill nickname = username where nickname is NULL or empty
  - Optionally report duplicates (case-insensitive) for manual resolution
"""
import os
import sys
import sqlite3
from contextlib import closing

# Make sure we can import app to know DB path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from app import app

DB_PATH = app.config['SQLALCHEMY_DATABASE_URI'].replace('sqlite:///', '')

def column_exists(conn, table, column):
    with closing(conn.cursor()) as cur:
        cur.execute(f"PRAGMA table_info({table})")
        cols = [row[1] for row in cur.fetchall()]
        return column in cols


def main():
    print("🚀 Running nickname migration...")
    print(f"Using database: {DB_PATH}")
    with sqlite3.connect(DB_PATH) as conn:
        conn.isolation_level = None  # autocommit for DDL

        if not column_exists(conn, 'user', 'nickname'):
            print("Adding column 'nickname' to table 'user' ...")
            conn.execute("ALTER TABLE user ADD COLUMN nickname TEXT")
            print("✓ Column added")
        else:
            print("✓ Column 'nickname' already exists")

        print("Backfilling nickname values...")
        conn.execute("UPDATE user SET nickname = username WHERE nickname IS NULL OR nickname = ''")
        print("✓ Backfill complete")

        print("Checking for case-insensitive duplicate nicknames...")
        query = (
            "SELECT lower(nickname) as nk, COUNT(*) cnt "
            "FROM user WHERE nickname IS NOT NULL AND nickname <> '' "
            "GROUP BY lower(nickname) HAVING cnt > 1"
        )
        cur = conn.execute(query)
        dups = cur.fetchall()
        if dups:
            print("⚠️  Found duplicate nicknames (case-insensitive):")
            for nk, cnt in dups:
                print(f"  - '{nk}' occurs {cnt} times")
            print("Please resolve duplicates manually. App enforces uniqueness at registration.")
        else:
            print("✓ No duplicate nicknames detected")

    print("🎉 Migration finished")

if __name__ == '__main__':
    main()
