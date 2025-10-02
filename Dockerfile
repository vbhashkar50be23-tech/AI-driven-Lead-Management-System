# syntax=docker/dockerfile:1
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System deps (optional: build tools if needed)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy project
COPY . /app

# Default command can be overridden by docker-compose
CMD ["uvicorn", "backend.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
