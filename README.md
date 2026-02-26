# Overture Buildings Explorer

Interactive explorer for building footprints from the [Overture Maps](https://overturemaps.org/) dataset. Built for development practitioners who need building data for planning, disaster response, and urbanization analysis.

## Features
- Full-screen WebGL map with satellite imagery
- Query building footprints by drawing areas or uploading GeoJSON
- Building metadata: height, floors, classification, data sources
- Export results as GeoJSON

## Quick Start

### Backend
```bash
uv sync
uv run uvicorn backend.app.main:app --reload
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173

## Tech Stack
- **Backend:** FastAPI + DuckDB (queries Overture Parquet on S3)
- **Frontend:** React + Deck.gl + MapLibre GL JS
