from fastapi.testclient import TestClient
import app as app_module
from app import app

client = TestClient(app)


def test_health_check():
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_get_members():
    """Test members endpoint returns data from the database layer."""
    sample_members = [
        {
            "id": 1,
            "name": "Joao Silva",
            "email": "joao@example.com",
            "join_date": "2024-01-15",
            "is_active": True,
            "created_at": "2024-01-15T10:00:00",
            "updated_at": "2024-01-15T10:00:00",
        }
    ]
    app_module.fetch_members = lambda: sample_members

    response = client.get("/api/members")

    assert response.status_code == 200
    assert response.json() == {"status": "success", "data": sample_members}


def test_get_togethers():
    """Test get-togethers endpoint returns data from the database layer."""
    sample_events = [
        {
            "id": 1,
            "title": "CI/CD Pipeline Workshop",
            "description": "Hands-on workshop",
            "event_date": "2024-06-10T18:30:00",
            "location": "Porto Innovation Lab",
            "max_attendees": 30,
            "created_at": "2024-06-01T10:00:00",
            "updated_at": "2024-06-01T10:00:00",
        }
    ]
    app_module.fetch_get_togethers = lambda: sample_events

    response = client.get("/api/get-togethers")

    assert response.status_code == 200
    assert response.json() == {"status": "success", "data": sample_events}


def test_create_member():
    """Test creating a member delegates to the database layer."""
    created_member = {
        "id": 5,
        "name": "Ana Ferreira",
        "email": "ana@example.com",
        "join_date": "2024-03-10",
        "is_active": True,
        "created_at": "2024-03-10T11:00:00",
        "updated_at": "2024-03-10T11:00:00",
    }
    app_module.insert_member = lambda payload: created_member

    response = client.post(
        "/api/members",
        json={"name": "Ana Ferreira", "email": "ana@example.com"},
    )

    assert response.status_code == 201
    assert response.json() == {"status": "success", "data": created_member}


def test_create_get_together():
    """Test creating a get-together delegates to the database layer."""
    created_event = {
        "id": 9,
        "title": "DevOps Porto Meetup",
        "description": "Infra and platform talks",
        "event_date": "2024-07-01T18:30:00",
        "location": "Porto",
        "max_attendees": 80,
        "created_at": "2024-06-01T11:00:00",
        "updated_at": "2024-06-01T11:00:00",
    }
    app_module.insert_get_together = lambda payload: created_event

    response = client.post(
        "/api/get-togethers",
        json={
            "title": "DevOps Porto Meetup",
            "description": "Infra and platform talks",
            "event_date": "2024-07-01T18:30:00",
            "location": "Porto",
            "max_attendees": 80,
        },
    )

    assert response.status_code == 201
    assert response.json() == {"status": "success", "data": created_event}


def test_not_found():
    """Test 404 error handling"""
    response = client.get("/api/invalid-endpoint")
    assert response.status_code == 404
