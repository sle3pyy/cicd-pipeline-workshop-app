from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="DevOps Porto Get-Together API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# TODO: Configure database connection
# DB_URL = os.getenv('DATABASE_URL', 'postgresql://user:password@localhost:5432/workshop_db')


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
    """TODO: Implement retrieving all members from database"""
    return {
        "message": "Members endpoint - implement me!",
        "status": "pending",
        "data": []
    }


@app.post("/api/members", status_code=201)
def create_member():
    """TODO: Implement creating a new member"""
    return {
        "message": "Create member endpoint - implement me!",
        "status": "pending"
    }


# Get-togethers API endpoints

@app.get("/api/get-togethers")
def get_meetups():
    """TODO: Implement retrieving all get-together events from database"""
    return {
        "message": "Get-togethers endpoint - implement me!",
        "status": "pending",
        "data": []
    }


@app.post("/api/get-togethers", status_code=201)
def create_meetup():
    """TODO: Implement creating a new get-together event"""
    return {
        "message": "Create get-together endpoint - implement me!",
        "status": "pending"
    }
