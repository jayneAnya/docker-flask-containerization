# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Stage 2: Runtime

FROM python:3.12-slim

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Create non-root user
RUN useradd --create-home appuser

# Copy application
COPY app.py .

# Give application user ownership
RUN chown -R appuser:appuser /app

USER appuser

# Document application port
EXPOSE 5000

# Docker health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000')" || exit 1

# Start application
CMD ["python", "app.py"]
