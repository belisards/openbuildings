from backend.app.core.duckdb import get_connection

def test_duckdb_connection_has_spatial():
    con = get_connection()
    result = con.execute("SELECT ST_Point(0, 0)").fetchone()
    assert result is not None

def test_duckdb_connection_has_httpfs():
    con = get_connection()
    result = con.execute("SELECT current_setting('s3_region')").fetchone()
    assert result[0] == "us-west-2"
