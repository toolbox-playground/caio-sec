# 🐍 Snyk - Guia Completo

> Análise de segurança de código, dependências, containers e IaC com integração ao ecossistema de desenvolvimento

---

## 📋 Índice

- [O que é Snyk?](#o-que-é-snyk)
- [Tipos de scan](#tipos-de-scan)
- [Como instalar](#como-instalar)
- [Obtendo seu token](#obtendo-seu-token)
- [Configurar SNYK_TOKEN no GitHub](#configurar-snyk_token-no-github)
- [Comandos principais](#comandos-principais)
- [Integração CI/CD](#integração-cicd)
- [Exemplos práticos](#exemplos-práticos)
- [Links úteis](#links-úteis)

---

## 🔍 O que é Snyk?

**Snyk** é uma plataforma de segurança para desenvolvedores fundada em 2015. É amplamente reconhecida por tornar a segurança **parte natural do fluxo de desenvolvimento** (shift-left security).

### Por que Snyk se destaca?
- 🤖 **Fix automático**: Sugere e aplica correções automaticamente
- 🔄 **Monitoramento contínuo**: Alerta quando novas CVEs afetam suas dependências
- 🛠️ **Integração rica**: IDE plugins, GitHub, GitLab, Jira, Slack, etc.
- 📊 **Banco de dados proprietário**: Snyk Vulnerability Database com dados exclusivos
- 🎓 **Educacional**: Explica vulnerabilidades com exemplos e contexto
- 💚 **Freemium**: Plano gratuito generoso para projetos open-source

---

## 🎯 Tipos de scan

| Produto | Comando | O que analisa |
|---------|---------|---------------|
| **Snyk Open Source** | `snyk test` | Dependências de terceiros (npm, pip, maven, etc.) |
| **Snyk Code** | `snyk code test` | Seu próprio código-fonte (SAST) |
| **Snyk Container** | `snyk container test` | Imagens Docker e packages do OS |
| **Snyk IaC** | `snyk iac test` | Terraform, Kubernetes, CloudFormation, ARM |
| **Snyk Monitor** | `snyk monitor` | Monitora continuamente (salva snapshot) |

### Ecossistemas suportados pelo Snyk Open Source:
| Linguagem | Arquivos |
|-----------|---------|
| JavaScript/Node | `package.json`, `yarn.lock` |
| Python | `requirements.txt`, `Pipfile`, `pyproject.toml` |
| Java | `pom.xml`, `build.gradle` |
| .NET | `.csproj`, `packages.config` |
| Go | `go.mod` |
| Ruby | `Gemfile` |
| PHP | `composer.json` |
| Swift/Cocoa | `Package.swift`, `Podfile` |

---

## 📦 Como instalar

### Método 1: npm (Usado na pipeline) — Recomendado
```bash
# Instala globalmente via npm
npm install -g snyk

# Verifica versão
snyk --version

# Atualiza para versão mais recente
npm update -g snyk
```

### Método 2: Homebrew (macOS/Linux)
```bash
brew tap snyk/tap
brew install snyk-cli
```

### Método 3: Scoop (Windows)
```powershell
scoop bucket add snyk https://github.com/snyk/scoop-snyk
scoop install snyk
```

### Método 4: Download direto
Acesse: [https://github.com/snyk/cli/releases](https://github.com/snyk/cli/releases)

```bash
# Linux
curl --compressed https://downloads.snyk.io/cli/stable/snyk-linux \
  -o snyk
chmod +x snyk
sudo mv snyk /usr/local/bin/
```

### Método 5: Docker
```bash
# Scan de dependências
docker run --rm \
  -v "$(pwd):/project" \
  -e SNYK_TOKEN=$SNYK_TOKEN \
  snyk/snyk:python-3.11 \
  snyk test --file=/project/requirements.txt
```

---

## 🔐 Obtendo seu token

### Passo a passo:

**1. Criar conta gratuita:**
```
1. Acesse: https://app.snyk.io/login
2. Faça login com GitHub, Google ou email
3. Complete o onboarding inicial
```

**2. Obter o token:**
```
1. Acesse: https://app.snyk.io/account
2. Role até "Auth Token"
3. Clique em "click to show"
4. Copie o token (formato: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
```

**3. Testar o token:**
```bash
# Substitua pelo seu token real
export SNYK_TOKEN="seu-token-aqui"
snyk auth $SNYK_TOKEN

# Ou autentique interativamente (abre browser)
snyk auth
```

---

## 🔑 Configurar SNYK_TOKEN no GitHub

Para usar o Snyk nas suas pipelines do GitHub Actions:

### Passo a passo:

```
1. No seu repositório GitHub, clique em "Settings"
2. No menu lateral, clique em "Secrets and variables" > "Actions"
3. Clique em "New repository secret"
4. Nome: SNYK_TOKEN
5. Valor: seu-token-do-snyk-aqui
6. Clique em "Add secret"
```

### Verificando na pipeline:
```yaml
# Na pipeline GitHub Actions
- name: Autenticar Snyk
  run: snyk auth ${{ secrets.SNYK_TOKEN }}
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

### Nível de organização (opcional):
Para usar em múltiplos repositórios sem repetir o secret:
```
1. Acesse: github.com/organizations/NOME-ORG/settings/secrets
2. Adicione como "organization secret"
3. Selecione quais repositórios podem usar
```

---

## 🛠️ Comandos principais

### `snyk test` — Testa vulnerabilidades em dependências
```bash
# Dependências Python
snyk test --file=requirements.txt --package-manager=pip

# Dependências Node.js
snyk test --file=package.json

# Dependências Java (Maven)
snyk test --file=pom.xml

# Todos os projetos no monorepo
snyk test --all-projects

# Com threshold de severidade (falha se CRITICAL)
snyk test --severity-threshold=critical

# Output JSON
snyk test --json --json-file-output=snyk-report.json

# Mostra apenas vulnerabilidades com fix disponível
snyk test --show-vulnerable-paths=all
```

### `snyk code test` — Análise SAST do código
```bash
# Analisa código-fonte
snyk code test

# Analisa diretório específico
snyk code test ./src

# Com output JSON
snyk code test --json > snyk-code-report.json

# Com severidade mínima
snyk code test --severity-threshold=high
```

### `snyk container test` — Scan de containers
```bash
# Testa imagem com Dockerfile para contexto
snyk container test minha-app:latest \
  --file=Dockerfile

# Testa imagem do registry
snyk container test nginx:latest

# Com output JSON
snyk container test minha-app:latest \
  --file=Dockerfile \
  --json \
  --json-file-output=container-report.json

# Falha apenas em CRITICAL
snyk container test minha-app:latest \
  --severity-threshold=critical
```

### `snyk iac test` — Análise de IaC
```bash
# Terraform
snyk iac test examples/terraform/

# Kubernetes
snyk iac test k8s-manifests/

# Múltiplos arquivos
snyk iac test --recursive .

# Com output JSON
snyk iac test examples/terraform/ \
  --json \
  --json-file-output=iac-report.json

# Falha em HIGH e CRITICAL
snyk iac test . --severity-threshold=high
```

### `snyk monitor` — Monitoramento contínuo
```bash
# Monitora projeto (salva snapshot no Snyk.io)
snyk monitor --file=requirements.txt --package-manager=pip

# Com nome do projeto customizado
snyk monitor \
  --project-name="meu-projeto-producao" \
  --file=package.json
```

### `snyk fix` — Correção automática (requer flag)
```bash
# Aplica fixes automáticos
snyk fix --interactive

# Fix sem interação (modo batch)
snyk fix
```

---

## 🔗 Integração CI/CD

### GitHub Actions (manual, sem action pronta)
```yaml
jobs:
  snyk-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Instalar Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Instalar Snyk via npm
        run: npm install -g snyk

      - name: Autenticar Snyk
        run: snyk auth $SNYK_TOKEN
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Snyk - Dependências
        run: |
          snyk test \
            --file=requirements.txt \
            --package-manager=pip \
            --json \
            --json-file-output=snyk-deps.json || true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Snyk - Container
        run: |
          docker build -t minha-app .
          snyk container test minha-app:latest \
            --file=Dockerfile \
            --json \
            --json-file-output=snyk-container.json || true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Snyk - IaC
        run: |
          snyk iac test terraform/ \
            --json \
            --json-file-output=snyk-iac.json || true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Upload artefatos
        uses: actions/upload-artifact@v4
        with:
          name: snyk-reports
          path: snyk-*.json
```

### GitLab CI
```yaml
snyk-scan:
  image: node:20-slim
  script:
    - npm install -g snyk
    - snyk auth $SNYK_TOKEN
    - snyk test --file=requirements.txt --package-manager=pip || true
    - snyk iac test terraform/ || true
  artifacts:
    paths:
      - snyk-*.json
  only:
    - main
    - merge_requests
```

---

## 📖 Exemplos práticos

### Exemplo 1: Verificando vulnerabilidades das dependências do projeto
```bash
export SNYK_TOKEN="seu-token"
snyk auth $SNYK_TOKEN

# Analisa o requirements.txt vulnerável do projeto
snyk test \
  --file=examples/python/requirements.txt \
  --package-manager=pip \
  --severity-threshold=medium
```

**Saída esperada:**
```
✗ High severity vulnerability found in flask
  Description: Open Redirect
  Info: https://security.snyk.io/vuln/SNYK-PYTHON-FLASK-xxx
  Introduced through: flask@2.0.1
  Fix suggestion: Upgrade to flask@2.3.3

✗ Medium severity vulnerability found in requests
  Description: Improper Input Validation
  Introduced through: requests@2.25.0
  Fix suggestion: Upgrade to requests@2.31.0

Tested 7 dependencies for known issues.
Found 5 issues, 5 vulnerable paths.
```

### Exemplo 2: Monitorando um projeto de produção
```bash
# Cria snapshot para monitoramento contínuo
snyk monitor \
  --file=requirements.txt \
  --package-manager=pip \
  --project-name="meu-app-producao"

# Snyk irá alertar por email quando novas CVEs surgirem
```

### Exemplo 3: Lendo relatório JSON
```python
# parse_snyk.py — Extrai informações do relatório JSON
import json

with open('snyk-deps.json') as f:
    report = json.load(f)

if 'vulnerabilities' in report:
    print(f"Total de vulnerabilidades: {len(report['vulnerabilities'])}")
    for vuln in report['vulnerabilities']:
        severity = vuln.get('severity', 'unknown')
        title = vuln.get('title', 'Unknown')
        pkg = vuln.get('packageName', 'unknown')
        fix = vuln.get('fixedIn', ['Sem fix disponível'])
        print(f"[{severity.upper()}] {pkg}: {title} → Fix: {fix}")
```

---

## 🔗 Links úteis

| Recurso | URL |
|---------|-----|
| Snyk.io | [https://app.snyk.io/](https://app.snyk.io/) |
| Obter token | [https://app.snyk.io/account](https://app.snyk.io/account) |
| Documentação CLI | [https://docs.snyk.io/snyk-cli](https://docs.snyk.io/snyk-cli) |
| Banco de vulnerabilidades | [https://security.snyk.io/](https://security.snyk.io/) |
| GitHub Releases (CLI) | [https://github.com/snyk/cli/releases](https://github.com/snyk/cli/releases) |
| Snyk Learn (cursos) | [https://learn.snyk.io/](https://learn.snyk.io/) |
| Status de integrações | [https://docs.snyk.io/integrate-with-snyk](https://docs.snyk.io/integrate-with-snyk) |

---

> **Dica pro**: Use `snyk monitor` em produção para receber alertas automáticos quando **novas CVEs** forem descobertas que afetam suas dependências — mesmo sem fazer nenhum deploy novo!
