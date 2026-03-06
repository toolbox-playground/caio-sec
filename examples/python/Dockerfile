# =============================================================================
# ⚠️  DOCKERFILE PROPOSITALMENTE VULNERÁVEL - APENAS PARA FINS DIDÁTICOS  ⚠️
# =============================================================================
# Este Dockerfile contém vulnerabilidades INTENCIONAIS para demonstrar como
# ferramentas como Trivy, Checkov e Snyk detectam problemas em containers.
#
# NÃO USE EM PRODUÇÃO!
#
# Vulnerabilidades presentes:
#   1. Imagem base desatualizada (Python 3.8 - EOL)
#   2. Executando como root (sem USER não-privilegiado)
#   3. Segredos no ENV (expostos em runtime e layers)
#   4. Sem HEALTHCHECK definido
#   5. Sem limites de recursos
#   6. apt-get sem --no-install-recommends
#   7. Dependências vulneráveis instaladas via requirements.txt
# =============================================================================

# ⚠️ VULNERABILIDADE #1: Versão antiga com CVEs conhecidos
# Use python:3.12-slim-bookworm em produção
FROM python:3.8

# Metadados do container
LABEL maintainer="caio@devsecops.example.com"
LABEL version="1.0.0"
LABEL description="Exemplo VULNERÁVEL para fins didáticos - NÃO USE EM PRODUÇÃO"

# ⚠️ VULNERABILIDADE #2: Segredos hardcoded como variáveis de ambiente
# Ficam expostos no histórico de layers e em inspeções do container
ENV DATABASE_PASSWORD="admin123" \
    API_KEY="sk-proj-abc123xyz456def789" \
    AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE" \
    AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
    FLASK_ENV="development" \
    FLASK_DEBUG="1"

# Define diretório de trabalho
WORKDIR /app

# ⚠️ VULNERABILIDADE #3: Instalando pacotes desnecessários sem cleanup
# Aumenta a superfície de ataque e o tamanho da imagem
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    net-tools \
    netcat-openbsd \
    telnet \
    # Os pacotes acima são desnecessários para uma app Flask
    && apt-get clean

# Copia arquivos de dependências
COPY requirements.txt .

# ⚠️ VULNERABILIDADE #4: Dependências desatualizadas com CVEs conhecidos
RUN pip install --no-cache-dir -r requirements.txt

# Copia código da aplicação
COPY . .

# ⚠️ VULNERABILIDADE #5: Sem definir usuário não-privilegiado
# A aplicação roda como ROOT por padrão
# Adicione: RUN useradd -r appuser && USER appuser

# ⚠️ VULNERABILIDADE #6: Sem HEALTHCHECK definido
# Adicione em produção:
# HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:5000/health || exit 1

# Expõe a porta da aplicação
EXPOSE 5000

# ⚠️ VULNERABILIDADE #7: Usando shell form em CMD (vulnerável a signal handling)
# Use exec form: CMD ["python", "app.py"]
CMD python app.py
