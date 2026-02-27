import logging
import threading
import duckdb

from backend.app.core.config import OVERTURE_S3_PATH

logger = logging.getLogger(__name__)

_connection: duckdb.DuckDBPyConnection | None = None
_warmup_done = threading.Event()
_warmup_thread: threading.Thread | None = None


def get_connection() -> duckdb.DuckDBPyConnection:
    global _connection
    if _connection is None:
        _connection = duckdb.connect()
        _connection.install_extension("spatial")
        _connection.install_extension("httpfs")
        _connection.load_extension("spatial")
        _connection.load_extension("httpfs")
        _connection.execute("SET s3_region = 'us-west-2'")
        _connection.execute("SET memory_limit = '2GB'")
        _connection.execute("SET threads = 4")
    return _connection


def is_warm() -> bool:
    return _warmup_done.is_set()


def warmup_metadata():
    """Pre-fetch Parquet file metadata so subsequent queries are fast (~6-12s instead of ~2.5min)."""
    global _warmup_thread
    if _warmup_done.is_set() or (_warmup_thread and _warmup_thread.is_alive()):
        return

    def _warmup():
        logger.info("Warming up Overture Parquet metadata (this takes ~2-3 minutes on first run)...")
        try:
            con = get_connection()
            con.execute(f"""
                SELECT count(*) FROM read_parquet('{OVERTURE_S3_PATH}')
                WHERE bbox.xmin >= 0 AND bbox.xmax <= 0.001
                  AND bbox.ymin >= 0 AND bbox.ymax <= 0.001
            """).fetchone()
            _warmup_done.set()
            logger.info("Metadata warmup complete. Queries will now be fast.")
        except Exception as e:
            logger.error(f"Metadata warmup failed: {e}")

    _warmup_thread = threading.Thread(target=_warmup, daemon=True)
    _warmup_thread.start()
