# =============================================================================
# Dockerfile hardenizado para exemplo de correção do Lab 001 DevSecOps
# =============================================================================

FROM python:3.13-alpine3.22

LABEL maintainer="caio@devsecops.example.com"
LABEL version="2.0.0"
LABEL description="Exemplo corrigido para fins didáticos"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_ENV=production

WORKDIR /app

RUN apk --no-cache update && apk --no-cache upgrade

COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

COPY app.py ./

RUN addgroup -S appgroup && adduser -S appuser -G appgroup && chown -R appuser:appgroup /app
USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=3)"

EXPOSE 5000
CMD ["python", "app.py"]
