import pytest
from fastapi.testclient import TestClient
from app import app

client = TestClient(app)


def test_health_check():
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_get_members():
    """Test members endpoint returns 200"""
    response = client.get("/api/members")
    assert response.status_code == 200


def test_get_togethers():
    """Test get-togethers endpoint returns 200"""
    response = client.get("/api/get-togethers")
    assert response.status_code == 200


def test_not_found():
    """Test 404 error handling"""
    response = client.get("/api/invalid-endpoint")
    assert response.status_code == 404
