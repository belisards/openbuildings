from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

NAIROBI_POLYGON = {
    "type": "Polygon",
    "coordinates": [[
        [36.817, -1.283],
        [36.820, -1.283],
        [36.820, -1.280],
        [36.817, -1.280],
        [36.817, -1.283],
    ]]
}

def test_health():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_buildings_endpoint():
    response = client.post("/api/buildings", json={
        "geometry": NAIROBI_POLYGON,
        "limit": 5,
    })
    assert response.status_code == 200
    data = response.json()
    assert data["type"] == "FeatureCollection"
    assert "metadata" in data

def test_buildings_stats_endpoint():
    response = client.post("/api/buildings/stats", json={
        "geometry": NAIROBI_POLYGON,
        "limit": 10,
    })
    assert response.status_code == 200
    data = response.json()
    assert "total_buildings" in data
