import json
from typing import Any

from shapely.geometry import shape
from backend.app.core.config import OVERTURE_S3_PATH, DEFAULT_FEATURE_LIMIT, INDEX_PATH
from backend.app.core.duckdb import get_connection


def _get_matching_files(con, bounds: tuple[float, float, float, float]) -> list[str]:
    """Use the local file index to find only the parquet files whose bbox overlaps the query area."""
    minx, miny, maxx, maxy = bounds
    rows = con.execute(f"""
        SELECT file_name FROM '{INDEX_PATH}'
        WHERE xmax >= $1 AND xmin <= $2
          AND ymax >= $3 AND ymin <= $4
    """, [minx, maxx, miny, maxy]).fetchall()
    return [r[0] for r in rows]


def query_buildings(geometry: dict[str, Any], limit: int = DEFAULT_FEATURE_LIMIT) -> dict[str, Any]:
    geom = shape(geometry)
    bounds = geom.bounds  # (minx, miny, maxx, maxy)
    geom_wkt = geom.wkt
    con = get_connection()

    if INDEX_PATH.exists():
        files = _get_matching_files(con, bounds)
        if not files:
            return {"type": "FeatureCollection", "features": []}
        source = f"read_parquet({files})"
    else:
        source = f"read_parquet('{OVERTURE_S3_PATH}')"

    sql = f"""
    SELECT
        id,
        ST_AsGeoJSON(geometry) AS geojson_geom,
        height,
        num_floors,
        class,
        subtype,
        names.primary AS primary_name,
        facade_color,
        facade_material,
        roof_material,
        roof_shape,
        roof_color,
        JSON(sources) AS sources
    FROM {source}
    WHERE
        bbox.xmin >= $1 AND bbox.xmax <= $2
        AND bbox.ymin >= $3 AND bbox.ymax <= $4
        AND ST_Intersects(geometry, ST_GeomFromText($5))
    LIMIT $6
    """

    result = con.execute(sql, [bounds[0], bounds[2], bounds[1], bounds[3], geom_wkt, limit])
    rows = result.fetchall()
    columns = [desc[0] for desc in result.description]

    features = []
    for row in rows:
        record = dict(zip(columns, row))
        geojson_geom = json.loads(record.pop("geojson_geom"))

        properties = {}
        for key, value in record.items():
            if value is not None:
                if key == "sources":
                    properties[key] = json.loads(value) if isinstance(value, str) else value
                else:
                    properties[key] = value

        features.append({
            "type": "Feature",
            "geometry": geojson_geom,
            "properties": properties,
        })

    return {"type": "FeatureCollection", "features": features}
