FROM python:3.11-slim

LABEL maintainer="homelab-log-analyzer"
LABEL description="Docker log analyzer with local LLM integration"

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY log_analyzer.py .

# Expose API port
EXPOSE 8765

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8765/health')"

# Run the application
CMD ["uvicorn", "log_analyzer:app", "--host", "0.0.0.0", "--port", "8765"]
