# 🔵 SonarQube — Guia Completo

> **Fonte oficial**: [https://docs.sonarsource.com/sonarqube-server/latest](https://docs.sonarsource.com/sonarqube-server/latest)  
> Documentação verificada via [Context7](https://context7.com) • Março de 2026

---

## 📋 Índice

- [🧠 O que é o SonarQube?](#-o-que-é-o-sonarqube)
- [🆚 SonarQube Server vs SonarQube Cloud](#-sonarqube-server-vs-sonarqube-cloud)
- [📦 Como instalar](#-como-instalar)
- [⚙️ Configuração inicial](#️-configuração-inicial)
- [🔍 sonar-project.properties](#-sonar-projectproperties)
- [🚀 Integração com GitHub Actions](#-integração-com-github-actions)
- [🚦 Quality Gates](#-quality-gates)
- [🔐 Security Hotspots e Vulnerabilidades](#-security-hotspots-e-vulnerabilidades)
- [📊 Métricas principais](#-métricas-principais)
- [🛠️ Comandos do sonar-scanner](#️-comandos-do-sonar-scanner)
- [🔗 Integração com este projeto](#-integração-com-este-projeto)
- [⚙️ sonar-project.properties para este repositório](#️-sonar-projectproperties-para-este-repositório)
- [🔍 Troubleshooting](#-troubleshooting)
- [🔗 Links úteis](#-links-úteis)

---

## 🧠 O que é o SonarQube?

O **SonarQube** é uma plataforma de inspeção contínua da qualidade e segurança do código. Analisa o código-fonte em busca de:

| Categoria | Exemplos |
|-----------|---------|
| 🔐 **Vulnerabilidades** | SQL Injection, XSS, Path Traversal, SSRF |
| 🔥 **Security Hotspots** | Código sensível que requer revisão humana |
| 🐛 **Bugs** | Comportamentos incorretos e referências nulas |
| 💩 **Code Smells** | Problemas de manutenibilidade e duplicação |
| 📏 **Cobertura de testes** | Linhas cobertas por testes unitários |
| 🧬 **Duplicação** | Código duplicado e blocos repetidos |

### Suporte a linguagens (30+)

Python, Java, JavaScript, TypeScript, Go, C#, C/C++, Ruby, Kotlin, Swift, PHP, Terraform, Dockerfile, YAML e muito mais.

---

## 🆚 SonarQube Server vs SonarQube Cloud

| Aspecto | SonarQube Server | SonarQube Cloud |
|---------|-----------------|----------------|
| **Hospedagem** | On-premises (sua infra) | SaaS (nuvem Sonar) |
| **Custo** | Community Build = grátis | Grátis para repos públicos |
| **Setup** | Docker ou instalação manual | Apenas OAuth com GitHub |
| **Dados** | Ficam no seu servidor | Ficam na nuvem |
| **SONAR_HOST_URL** | Seu servidor (ex: `http://localhost:9000`) | `https://sonarcloud.io` |
| **Ideal para** | Empresas, repos privados, compliance | Open source, projetos individuais |

> 💡 **Recomendação para este projeto**: use o **SonarQube Cloud** (grátis para repositórios públicos) ou o **SonarQube Server via Docker** para testes locais.

---

## 📦 Como instalar

### 🐧 Linux / 🪟 Windows / 🍎 macOS — Docker (Recomendado para testes locais)

```bash
# Iniciar SonarQube Server localmente (porta 9000)
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:community

# Verificar se está rodando
docker logs -f sonarqube

# Acessar: http://localhost:9000
# Login padrão: admin / admin (troque na primeira entrada!)
```

```powershell
# Windows PowerShell
docker run -d `
  --name sonarqube `
  -p 9000:9000 `
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true `
  sonarqube:community
```

### 🐧 Linux — Docker Compose (dados persistentes)

```yaml
# docker-compose.yml
version: "3"
services:
  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions

volumes:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:
```

```bash
docker compose up -d
```

### 🐧 Linux — sonar-scanner CLI (client)

```bash
# Baixa e extrai o scanner
SCANNER_VERSION="6.2.1.4610"
curl -sSL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SCANNER_VERSION}-linux-x64.zip" \
  -o /tmp/sonar-scanner.zip
unzip /tmp/sonar-scanner.zip -d /opt/
sudo ln -s /opt/sonar-scanner-${SCANNER_VERSION}-linux-x64/bin/sonar-scanner /usr/local/bin/sonar-scanner
sonar-scanner --version
```

### 🪟 Windows — sonar-scanner CLI (PowerShell)

```powershell
$VERSION = "6.2.1.4610"
$URL = "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${VERSION}-windows-x64.zip"
Invoke-WebRequest -Uri $URL -OutFile "$env:TEMP\sonar-scanner.zip"
Expand-Archive -Path "$env:TEMP\sonar-scanner.zip" -DestinationPath "C:\sonar-scanner"
# Adicione C:\sonar-scanner\bin ao PATH do sistema
[System.Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\sonar-scanner\sonar-scanner-${VERSION}-windows-x64\bin", "Machine")
sonar-scanner --version
```

### 🍎 macOS — Homebrew

```bash
brew install sonar-scanner
sonar-scanner --version
```

---

## ⚙️ Configuração inicial

### 1. Acessar a interface web

```
http://localhost:9000
Usuário: admin
Senha:   admin  →  troque imediatamente!
```

### 2. Criar um projeto

```
Projects → Create project → Manually
  Project display name: caio-sec
  Project key:          caio-sec
  Main branch name:     main
→ Set up → Locally → Generate token
```

### 3. Gerar o token de análise

```
My Account → Security → Generate token
  Name:  github-actions
  Type:  Project Analysis Token
  Expiry: 30 days (ou No expiration para CI)
→ Copie o token: sqp_xxxxxxxxxxxx
```

### 4. Salvar o token como secret no GitHub

```
Repositório → Settings → Secrets and variables → Actions
  SONAR_TOKEN     = sqp_xxxxxxxxxxxx
  SONAR_HOST_URL  = http://seu-servidor:9000   (ou https://sonarcloud.io)
```

---

## 🔍 sonar-project.properties

Crie na raiz do repositório:

```properties
# sonar-project.properties

# Identificação do projeto
sonar.projectKey=caio-sec
sonar.projectName=CaioDevSecOps
sonar.projectVersion=1.0

# Fontes a analisar
sonar.sources=examples/python,examples/terraform
sonar.exclusions=**/*.zip,**/*.tar.gz,**/__pycache__/**,**/.git/**

# Python
sonar.python.version=3.11
sonar.python.coverage.reportPaths=coverage.xml

# Encoding
sonar.sourceEncoding=UTF-8

# Quality Gate — reprovação com severidade Blocker ou Critical
sonar.qualitygate.wait=true
sonar.qualitygate.timeout=300
```

---

## 🚀 Integração com GitHub Actions

### Usando a GitHub Action oficial (SonarQube Cloud / Server)

```yaml
# .github/workflows/sonarqube.yml
name: 🔵 SonarQube Analysis

on:
  push:
    branches: [ "main" ]
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  sonarqube:
    name: SonarQube Scan
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0   # histórico completo para blame e branches

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies & run tests
        run: |
          pip install -r examples/python/requirements.txt
          pip install pytest pytest-cov
          pytest examples/python/ \
            --cov=examples/python \
            --cov-report=xml:coverage.xml \
            --ignore=examples/python/app.py \
            || true   # não bloqueia mesmo com falhas (código vulnerável intencional)

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
        with:
          args: >
            -Dsonar.projectKey=caio-sec
            -Dsonar.sources=examples/python,examples/terraform
            -Dsonar.python.version=3.11
            -Dsonar.python.coverage.reportPaths=coverage.xml
            -Dsonar.qualitygate.wait=true

      - name: SonarQube Quality Gate check
        uses: SonarSource/sonarqube-quality-gate-action@v1
        timeout-minutes: 5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

### Usando o sonar-scanner CLI diretamente

```yaml
# Alternativa: sem a action, usando o scanner CLI
      - name: SonarQube Scan (CLI)
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
        run: |
          sonar-scanner \
            -Dsonar.projectKey=caio-sec \
            -Dsonar.sources=examples/python \
            -Dsonar.host.url=$SONAR_HOST_URL \
            -Dsonar.token=$SONAR_TOKEN \
            -Dsonar.python.version=3.11 \
            -Dsonar.qualitygate.wait=true \
            -Dsonar.qualitygate.timeout=300
```

### Bloquear PR se Quality Gate falhar

```yaml
# Proteção de branch no GitHub:
# Settings → Branches → Branch protection rules → main
# ✅ Require status checks to pass before merging
#    Status check: "SonarQube Code Analysis"
```

```yaml
# No workflow: falhar o job se quality gate reprovar
      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
        with:
          args: -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=600
```

---

## 🚦 Quality Gates

O **Quality Gate** é o conjunto de condições que o código deve atender para ser aprovado.

### Quality Gate padrão ("Sonar way")

| Métrica | Condição |
|---------|---------|
| Security Rating | deve ser A |
| Reliability Rating | deve ser A |
| Maintainability Rating | deve ser A |
| Coverage (novos códigos) | ≥ 80% |
| Duplicated Lines (novos códigos) | ≤ 3% |
| Blocker Issues | 0 |

### Ratings explicados

| Rating | Significado | Vulnerabilidades |
|--------|-------------|-----------------|
| **A** | Nenhuma vulnerabilidade | 0 |
| **B** | Ao menos 1 vulnerabilidade menor | 1 low |
| **C** | Ao menos 1 vulnerabilidade média | 1 medium |
| **D** | Ao menos 1 vulnerabilidade alta | 1 high |
| **E** | Ao menos 1 vulnerabilidade crítica | 1 blocker ou critical |

### Customizar Quality Gate

```
Administration → Quality Gates → Create
  Adicione condições:
  - Vulnerabilities is greater than 0  →  bloqueador
  - Security Hotspots Reviewed < 100%  →  bloqueador
  - Coverage < 70%                      →  warning
```

---

## 🔐 Security Hotspots e Vulnerabilidades

### Diferença entre Vulnerability e Security Hotspot

| Tipo | Descrição | Ação necessária |
|------|-----------|-----------------|
| **Vulnerability** | Falha de segurança confirmada (ex: SQL Injection detectado) | Corrigir obrigatoriamente |
| **Security Hotspot** | Código sensível que **pode** ser inseguro dependendo do contexto | Revisar e marcar como Safe ou Fix |

### Exemplos de regras que detectam o `examples/python/app.py` deste projeto

| Regra | Tipo | Descrição |
|-------|------|-----------|
| `python:S3649` | Vulnerability | SQL queries should not be vulnerable to injection attacks |
| `python:S4790` | Vulnerability | Using weak hashing algorithms (MD5) is security-sensitive |
| `python:S2076` | Vulnerability | OS commands should not be vulnerable to injection attacks |
| `python:S5247` | Hotspot | Disabling Django CSRF validation is security-sensitive |
| `python:S1523` | Hotspot | Executing code dynamically is security-sensitive |

### Fluxo de revisão de Security Hotspots

```
Security → Security Hotspots → [lista de hotspots]
  Para cada hotspot:
    → "Safe": confirmado que NÃO é problema no contexto
    → "Fixed": vulnerabilidade corrigida
    → "Acknowledged": ciente do risco, decisão de aceitar
```

---

## 📊 Métricas principais

| Métrica | O que mede | Comando |
|---------|-----------|---------|
| `sonar.coverage` | % de linhas cobertas por testes | `pytest --cov` |
| `sonar.duplicated_lines_density` | % de linhas duplicadas | automático |
| `sonar.security_rating` | Rating de segurança (A–E) | automático |
| `sonar.reliability_rating` | Rating de confiabilidade (A–E) | automático |
| `sonar.sqale_rating` | Rating de manutenibilidade (A–E) | automático |
| `sonar.bugs` | Número de bugs detectados | automático |
| `sonar.vulnerabilities` | Número de vulnerabilidades | automático |
| `sonar.code_smells` | Número de code smells | automático |
| `sonar.security_hotspots` | Hotspots aguardando revisão | automático |

---

## 🛠️ Comandos do sonar-scanner

### Scan básico local

```bash
# Aponta para servidor local (Docker)
sonar-scanner \
  -Dsonar.projectKey=caio-sec \
  -Dsonar.sources=examples/python \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=SEU_TOKEN_AQUI

# Scan excluindo pastas
sonar-scanner \
  -Dsonar.projectKey=caio-sec \
  -Dsonar.sources=. \
  -Dsonar.exclusions="**/__pycache__/**,**/.git/**,**/node_modules/**" \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=SEU_TOKEN_AQUI

# Scan com cobertura de testes
pytest examples/python/ --cov=examples/python --cov-report=xml:coverage.xml
sonar-scanner \
  -Dsonar.projectKey=caio-sec \
  -Dsonar.sources=examples/python \
  -Dsonar.python.coverage.reportPaths=coverage.xml \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=SEU_TOKEN_AQUI
```

### Scan via Docker (sem instalar o scanner)

```bash
# Linux/macOS
docker run --rm \
  --network host \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli \
  sonar-scanner \
    -Dsonar.projectKey=caio-sec \
    -Dsonar.sources=/usr/src/examples/python \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=SEU_TOKEN_AQUI
```

```powershell
# Windows PowerShell
docker run --rm `
  --network host `
  -v "${PWD}:/usr/src" `
  sonarsource/sonar-scanner-cli `
  sonar-scanner `
    -Dsonar.projectKey=caio-sec `
    -Dsonar.sources=/usr/src/examples/python `
    -Dsonar.host.url=http://host.docker.internal:9000 `
    -Dsonar.token=SEU_TOKEN_AQUI
```

---

## 🔗 Integração com este projeto

O SonarQube complementa as ferramentas já presentes na `unified-security-pipeline.yaml`:

| O que outros fazem | O que SonarQube adiciona |
|--------------------|-------------------------|
| Gitleaks/TruffleHog detectam segredos no Git | SonarQube detecta segredos hardcoded no código-fonte |
| Trivy escaneia imagens e dependências | SonarQube analisa a **lógica** do código (data flow) |
| Checkov verifica IaC | SonarQube verifica IaC + código da aplicação |
| Snyk code test faz SAST básico | SonarQube SAST com **data flow completo** e histórico |

### Adicionar à pipeline unificada

```yaml
# Adicione ao .github/workflows/unified-security-pipeline.yaml
  sonarqube:
    name: 🔵 SonarQube
    runs-on: ubuntu-latest
    continue-on-error: true
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
        with:
          args: >
            -Dsonar.projectKey=caio-sec
            -Dsonar.sources=examples/python,examples/terraform
```

> **Secrets necessários**:
> - `SONAR_TOKEN` — token gerado no SonarQube (Server ou Cloud)
> - `SONAR_HOST_URL` — `http://seu-servidor:9000` ou `https://sonarcloud.io`

---

## ⚙️ sonar-project.properties para este repositório

Crie este arquivo na raiz do projeto para não precisar passar `-D` toda vez:

```properties
# sonar-project.properties — CaioDevSecOps

sonar.projectKey=caio-sec
sonar.projectName=CaioDevSecOps
sonar.projectVersion=1.0
sonar.projectDescription=Pipeline de Segurança Unificada para DevSecOps

# Fontes Python e Terraform
sonar.sources=examples/python,examples/terraform
sonar.exclusions=**/__pycache__/**,**/.terraform/**,**/*.zip,**/*.tar.gz

# Python
sonar.python.version=3.11

# Encoding
sonar.sourceEncoding=UTF-8

# Quality Gate
sonar.qualitygate.wait=true
sonar.qualitygate.timeout=300
```

---

## 🔍 Troubleshooting

### ❌ "Elasticsearch bootstrap checks failed"

```bash
# Aumentar o limite de memória virtual (Linux)
sudo sysctl -w vm.max_map_count=524288
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf

# Ou desabilitar os checks (só para desenvolvimento!)
docker run -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true sonarqube:community
```

### ❌ "Not authorized" ao fazer o scan

```bash
# Verifique se o token está correto
sonar-scanner -Dsonar.token=SEU_TOKEN ...

# Token gerado em: My Account → Security → Generate Tokens
# Tipo: Project Analysis Token (não Global)
```

### ❌ "Could not find ref" / "Missing blame information"

```yaml
# No workflow, use fetch-depth: 0 para clone completo
- uses: actions/checkout@v4
  with:
    fetch-depth: 0
```

### ❌ Quality Gate reprovado por falta de cobertura

```bash
# Gere o relatório de cobertura ANTES do scan
pip install pytest pytest-cov
pytest --cov=. --cov-report=xml:coverage.xml

# Passe o caminho no scan
sonar-scanner -Dsonar.python.coverage.reportPaths=coverage.xml ...
```

### ❌ "sonarqube-scan-action: command not found" no Windows

```powershell
# Use o scanner via Docker no Windows local
docker run --rm -v "${PWD}:/usr/src" sonarsource/sonar-scanner-cli ...
```

---

## 🔗 Links úteis

| Recurso | URL |
|---------|-----|
| Documentação oficial (Server) | [docs.sonarsource.com/sonarqube-server](https://docs.sonarsource.com/sonarqube-server/latest) |
| Documentação oficial (Cloud) | [docs.sonarsource.com/sonarqube-cloud](https://docs.sonarsource.com/sonarqube-cloud) |
| GitHub Action oficial | [SonarSource/sonarqube-scan-action](https://github.com/SonarSource/sonarqube-scan-action) |
| SonarQube Community Build | [Docker Hub: sonarqube](https://hub.docker.com/_/sonarqube) |
| Regras Python | [rules.sonarsource.com/python](https://rules.sonarsource.com/python) |
| Quality Gate documentação | [docs — quality gates](https://docs.sonarsource.com/sonarqube-server/latest/quality-standards/quality-gates) |
| Integração GitHub Actions | [docs — github integration](https://docs.sonarsource.com/sonarqube-server/latest/devops-platform-integration/github-integration/introduction) |

### Relacionado neste repositório

| Ferramenta | Doc | Complementa SonarQube |
|------------|-----|-----------------------|
| [SNYK.md](SNYK.md) | SAST + dependências | Sobreposição parcial em SAST |
| [CHECKOV.md](CHECKOV.md) | Segurança de IaC | Sobreposição em Terraform |
| [TRIVY.md](TRIVY.md) | CVEs em containers e deps | Sobreposição em dependências |
| [GITHUB-CODE-SECURITY.md](GITHUB-CODE-SECURITY.md) | CodeQL nativo GitHub | Sobreposição em análise de código |

---

*Documentação verificada com [Context7](https://context7.com) • [docs.sonarsource.com](https://docs.sonarsource.com/sonarqube-server/latest) • Março de 2026*
