import os
from contextlib import contextmanager

import psycopg2
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from psycopg2 import OperationalError
from psycopg2.extras import RealDictCursor

from models import GetTogetherCreate, MemberCreate

load_dotenv()

app = FastAPI(title="DevOps Porto Get-Together API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_URL = os.getenv('DATABASE_URL', 'postgresql://user:password@localhost:5432/workshop_db')


@contextmanager
def get_db_cursor(commit: bool = False):
    try:
        with psycopg2.connect(DB_URL) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                yield cursor
            if commit:
                conn.commit()
    except OperationalError as exc:
        raise HTTPException(status_code=503, detail="Database unavailable") from exc
    except psycopg2.Error as exc:
        raise HTTPException(status_code=500, detail="Database query failed") from exc


def fetch_members():
    with get_db_cursor() as cursor:
        cursor.execute(
            """
            SELECT id, name, email, join_date, is_active, created_at, updated_at
            FROM members
            ORDER BY id
            """
        )
        return [dict(row) for row in cursor.fetchall()]


def insert_member(member: MemberCreate):
    with get_db_cursor(commit=True) as cursor:
        cursor.execute(
            """
            INSERT INTO members (name, email, join_date, is_active)
            VALUES (%s, %s, COALESCE(%s, CURRENT_DATE), %s)
            RETURNING id, name, email, join_date, is_active, created_at, updated_at
            """,
            (member.name, member.email, member.join_date, member.is_active),
        )
        return dict(cursor.fetchone())


def fetch_get_togethers():
    with get_db_cursor() as cursor:
        cursor.execute(
            """
            SELECT id, title, description, event_date, location, max_attendees, created_at, updated_at
            FROM events
            ORDER BY event_date
            """
        )
        return [dict(row) for row in cursor.fetchall()]


def insert_get_together(get_together: GetTogetherCreate):
    with get_db_cursor(commit=True) as cursor:
        cursor.execute(
            """
            INSERT INTO events (title, description, event_date, location, max_attendees)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id, title, description, event_date, location, max_attendees, created_at, updated_at
            """,
            (
                get_together.title,
                get_together.description,
                get_together.event_date,
                get_together.location,
                get_together.max_attendees,
            ),
        )
        return dict(cursor.fetchone())


@app.get("/health")
def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "DevOps Porto Get-Together Backend"
    }


# Members API endpoints

@app.get("/api/members")
def get_members():
    """Retrieve all members from the database."""
    return {
        "status": "success",
        "data": fetch_members(),
    }


@app.post("/api/members", status_code=201)
def create_member(member: MemberCreate):
    """Create a new member in the database."""
    return {
        "status": "success",
        "data": insert_member(member),
    }


# Get-togethers API endpoints

@app.get("/api/get-togethers")
def get_meetups():
    """Retrieve all get-together events from the database."""
    return {
        "status": "success",
        "data": fetch_get_togethers(),
    }


@app.post("/api/get-togethers", status_code=201)
def create_meetup(get_together: GetTogetherCreate):
    """Create a new get-together event in the database."""
    return {
        "status": "success",
        "data": insert_get_together(get_together),
    }
