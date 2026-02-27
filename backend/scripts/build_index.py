"""Build a file-level bbox index for Overture building parquet files.

Run once at deploy time:
    uv run python -m backend.scripts.build_index

Scans all parquet files on S3, extracts min/max bbox per file,
saves a small local index (~10KB). Query time then only reads
matching files instead of all 237.
"""
import time
from backend.app.core.duckdb import get_connection
from backend.app.core.config import OVERTURE_S3_PATH, INDEX_PATH

def main():
    con = get_connection()
    INDEX_PATH.parent.mkdir(parents=True, exist_ok=True)

    print(f"Building file index from {OVERTURE_S3_PATH}")
    print("This scans parquet metadata from S3 (~2-3 minutes)...")
    t0 = time.time()

    con.execute(f"""
        COPY (
            SELECT
                file_name,
                MIN(stats_min_value) FILTER (WHERE path_in_schema = 'bbox.xmin') AS xmin,
                MAX(stats_max_value) FILTER (WHERE path_in_schema = 'bbox.xmax') AS xmax,
                MIN(stats_min_value) FILTER (WHERE path_in_schema = 'bbox.ymin') AS ymin,
                MAX(stats_max_value) FILTER (WHERE path_in_schema = 'bbox.ymax') AS ymax,
                SUM(num_values) FILTER (WHERE path_in_schema = 'bbox.xmin') AS num_buildings
            FROM parquet_metadata('{OVERTURE_S3_PATH}')
            WHERE path_in_schema IN ('bbox.xmin', 'bbox.xmax', 'bbox.ymin', 'bbox.ymax')
            GROUP BY file_name
        ) TO '{INDEX_PATH}' (FORMAT PARQUET)
    """)

    result = con.execute(f"SELECT count(*), sum(num_buildings) FROM '{INDEX_PATH}'").fetchone()
    elapsed = time.time() - t0
    print(f"Done in {elapsed:.0f}s. Indexed {result[0]} files, {result[1]:,.0f} buildings total.")
    print(f"Saved to {INDEX_PATH}")

if __name__ == "__main__":
    main()
