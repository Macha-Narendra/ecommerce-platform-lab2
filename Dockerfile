# ==============================
# Builder Stage
# ==============================

FROM python:3.12-slim AS builder

ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip

RUN pip install --prefix=/install \
    --no-cache-dir \
    -r requirements.txt

# ==============================
# Final Runtime Stage
# ==============================

FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libpq5 \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m appuser

COPY --from=builder /install /usr/local

COPY . .

RUN chmod +x entrypoint.sh

# Change ownership
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

ENTRYPOINT ["./entrypoint.sh"]
