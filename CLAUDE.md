# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Overture Buildings Explorer — a building footprint explorer for development practitioners. FastAPI + DuckDB backend queries Overture Maps Parquet files on S3, React + Deck.gl frontend renders 100K+ building polygons on a WebGL map with floating overlay panels.

## Commands

### Backend
```bash
uv sync                                           # install dependencies
uv run uvicorn backend.app.main:app --reload      # dev server on :8000
uv run pytest backend/tests/ -v --timeout=120     # run all tests (first query may take 30-60s)
uv run pytest backend/tests/test_api.py -v        # run specific test file
```

### Frontend
```bash
cd frontend && npm install                        # install dependencies
cd frontend && npm run dev                        # dev server on :5173
```

### Docker
```bash
docker-compose up                                 # both services (backend :8000, frontend :5173)
```

## Architecture

- `backend/app/main.py` — FastAPI app entry point, serves React SPA static build in production
- `backend/app/core/config.py` — Overture release version and S3 paths
- `backend/app/core/duckdb.py` — singleton DuckDB connection with spatial + httpfs extensions
- `backend/app/core/queries.py` — building query with spatial filtering against Overture Parquet on S3
- `backend/app/api/buildings.py` — REST endpoints: `POST /api/buildings`, `POST /api/buildings/stats`, `POST /api/export`
- `backend/app/models/schemas.py` — Pydantic request/response models
- `frontend/src/components/MapView.tsx` — Deck.gl + MapLibre full-screen map
- `frontend/src/components/AreaSelector.tsx` — GeoJSON upload and drawing tools panel
- `frontend/src/components/DataSummary.tsx` — stats display, opacity slider, export button
- `frontend/src/components/DrawControl.tsx` — polygon/rectangle drawing via editable-layers

## Conventions

- Python deps managed with `uv`, always use `uv run` to execute
- Frontend uses npm, Vite, TypeScript, Tailwind CSS
- All API endpoints under `/api/`
- Vite proxies `/api` to backend at `localhost:8000` in dev
- Backend serves frontend static build from `frontend/dist` in production
- DuckDB connection is a module-level singleton (not per-request)

## Tech Stack

Python 3.11+ / FastAPI / DuckDB (spatial + httpfs) / React 18 / TypeScript / Deck.gl 9 / MapLibre GL JS / Tailwind CSS / Vite

## MCP Integrations

- **github-server**: GitHub operations
