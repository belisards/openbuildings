FROM python:3.11-slim AS base
WORKDIR /app
COPY pyproject.toml .
RUN pip install uv && uv sync

FROM base AS dev
COPY backend/ backend/

FROM node:22-slim AS frontend-build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

FROM base AS production
COPY backend/ backend/
COPY --from=frontend-build /app/dist frontend/dist
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "backend.app.main:app", "--host", "0.0.0.0"]
