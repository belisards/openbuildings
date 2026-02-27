from backend.app.core.queries import query_buildings

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

def test_query_buildings_returns_feature_collection():
    result = query_buildings(NAIROBI_POLYGON, limit=10)
    assert result["type"] == "FeatureCollection"
    assert isinstance(result["features"], list)

def test_query_buildings_has_properties():
    result = query_buildings(NAIROBI_POLYGON, limit=5)
    if result["features"]:
        feature = result["features"][0]
        assert "geometry" in feature
        assert "properties" in feature
        assert feature["geometry"]["type"] in ("Polygon", "MultiPolygon")
