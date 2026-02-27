import json
from typing import Any

from shapely.geometry import shape
from backend.app.core.config import OVERTURE_S3_PATH, DEFAULT_FEATURE_LIMIT
from backend.app.core.duckdb import get_connection


def query_buildings(geometry: dict[str, Any], limit: int = DEFAULT_FEATURE_LIMIT) -> dict[str, Any]:
    geom = shape(geometry)
    bounds = geom.bounds
    geom_wkt = geom.wkt

    con = get_connection()

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
    FROM read_parquet('{OVERTURE_S3_PATH}')
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
