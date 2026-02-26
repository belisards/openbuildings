import duckdb

_connection = None

def get_connection() -> duckdb.DuckDBPyConnection:
    global _connection
    if _connection is None:
        _connection = duckdb.connect()
        _connection.install_extension("spatial")
        _connection.install_extension("httpfs")
        _connection.load_extension("spatial")
        _connection.load_extension("httpfs")
        _connection.execute("SET s3_region = 'us-west-2'")
    return _connection
