# =============================================================================
# Dockerfile hardenizado para exemplo de correção do Lab 001 DevSecOps
# =============================================================================

FROM python:3.13-alpine3.21

LABEL maintainer="caio@devsecops.example.com"
LABEL version="2.0.0"
LABEL description="Exemplo corrigido para fins didáticos"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_ENV=production

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

COPY app.py ./

RUN groupadd --system appgroup && useradd --system --gid appgroup --create-home appuser && chown -R appuser:appgroup /app
USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=3)"

EXPOSE 5000
CMD ["python", "app.py"]
