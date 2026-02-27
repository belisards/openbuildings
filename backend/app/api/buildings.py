import json
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from io import BytesIO

from backend.app.models.schemas import BuildingQuery
from backend.app.core.queries import query_buildings
from backend.app.core.config import OVERTURE_RELEASE

router = APIRouter(prefix="/api")

@router.post("/buildings")
async def get_buildings(query: BuildingQuery):
    geojson = query_buildings(query.geometry, limit=query.limit)
    stats = _compute_stats(geojson["features"])
    return {
        **geojson,
        "metadata": {
            "total_buildings": len(geojson["features"]),
            "truncated": len(geojson["features"]) >= query.limit,
            "overture_release": OVERTURE_RELEASE,
            **stats,
        }
    }

@router.post("/buildings/stats")
async def get_building_stats(query: BuildingQuery):
    geojson = query_buildings(query.geometry, limit=query.limit)
    features = geojson["features"]
    stats = _compute_stats(features)
    return {"total_buildings": len(features), **stats}

@router.post("/export")
async def export_buildings(query: BuildingQuery):
    geojson = query_buildings(query.geometry, limit=query.limit)
    content = json.dumps(geojson, separators=(",", ":"))
    return StreamingResponse(
        BytesIO(content.encode()),
        media_type="application/geo+json",
        headers={"Content-Disposition": "attachment; filename=overture_buildings.geojson"},
    )

def _compute_stats(features: list) -> dict:
    heights = [f["properties"]["height"] for f in features if f["properties"].get("height")]
    floors = [f["properties"]["num_floors"] for f in features if f["properties"].get("num_floors")]
    classes = [f["properties"]["class"] for f in features if f["properties"].get("class")]

    source_counts: dict[str, int] = {}
    for f in features:
        sources = f["properties"].get("sources")
        if sources and isinstance(sources, list) and sources:
            dataset = sources[0].get("dataset", "Unknown")
            source_counts[dataset] = source_counts.get(dataset, 0) + 1

    total = len(features)
    return {
        "height_coverage_pct": round(len(heights) / total * 100) if total else 0,
        "floor_coverage_pct": round(len(floors) / total * 100) if total else 0,
        "class_coverage_pct": round(len(classes) / total * 100) if total else 0,
        "avg_height": round(sum(heights) / len(heights), 1) if heights else None,
        "source_breakdown": source_counts,
    }
