from typing import Any
from pydantic import BaseModel

class BuildingQuery(BaseModel):
    geometry: dict[str, Any]
    limit: int = 50_000

class BuildingStats(BaseModel):
    total_buildings: int
    height_coverage_pct: float
    floor_coverage_pct: float
    class_coverage_pct: float
    avg_height: float | None
    source_breakdown: dict[str, int]
