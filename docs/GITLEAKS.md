# 🔑 Gitleaks - Guia Completo

> Detecção de segredos e informações sensíveis em repositórios Git

---

## 📋 Índice

- [O que é Gitleaks?](#o-que-é-gitleaks)
- [Detect vs Protect](#detect-vs-protect)
- [Como instalar](#como-instalar)
- [Comandos principais](#comandos-principais)
- [Configuração customizada](#configuração-customizada)
- [Como usar em pre-commit](#como-usar-em-pre-commit)
- [Exemplos práticos](#exemplos-práticos)
- [Links úteis](#links-úteis)

---

## 🔍 O que é Gitleaks?

**Gitleaks** é uma ferramenta SAST (Static Application Security Testing) open-source escrita em Go, especializada em **detectar segredos, senhas, tokens e credenciais** em repositórios Git.

### Por que usar Gitleaks?

- 🔍 Analisa o **histórico completo** do Git (não apenas arquivos atuais)
- ⚡ **Extremamente rápido** (escrito em Go)
- 🎯 Detecta mais de **150 tipos** de segredos por padrão
- 🔧 **Altamente configurável** via arquivo `.gitleaks.toml`
- 🛡️ Funciona como **pre-commit hook** para prevenir commits acidentais
- 📊 Suporta múltiplos formatos de saída (JSON, SARIF, CSV)

### Tipos de segredos detectados:
- AWS Access Keys e Secret Keys
- Azure Storage Keys
- GitHub/GitLab Tokens
- Stripe, Twilio, SendGrid API Keys
- Google Cloud credentials
- Private Keys (RSA, DSA, EC)
- Basic Auth credentials em URLs
- JWT tokens
- E muito mais...

---

## 🔄 Subcomandos: git, dir, stdin

O Gitleaks possui três subcomandos principais (a partir da v8.18):

### 🔍 `git` — Análise do histórico Git
```bash
gitleaks git .
```
- Analisa **commits já existentes** no histórico
- Útil para **auditoria** de repositórios existentes
- Ideal para CI/CD para verificar código já commitado
- Suporta `--staged` para funcionar como pre-commit hook

### 📂 `dir` — Análise do filesystem (sem Git)
```bash
gitleaks dir .
```
- Analisa **arquivos no disco** sem precisar de histórico Git
- Ideal para escanear diretórios ou arquivos isolados
- Suporta scan recursivo de arquivos compactados (zip, tar) com `--max-archive-depth`

### 📥 `stdin` — Leitura de entrada padrão
```bash
cat arquivo.txt | gitleaks stdin
```
- Analisa dados **pipados** de outros comandos
- Útil para integrar com outras ferramentas

### Diferença visual:

```
gitleaks git: Analisa histórico completo
  commit 1 → ✅
  commit 2 → ✅
  commit 3 → ❌ SEGREDO ENCONTRADO!
  commit 4 → ✅
  (todos os commits são verificados)

gitleaks git --staged: Intercepta antes do commit
  git add secret.txt
  git commit → BLOCKED! ❌ Segredo detectado
  (commit nunca entra no histórico)

gitleaks dir: Analisa arquivos no disco
  /configs/settings.yaml → ❌ SEGREDO ENCONTRADO!
  /src/main.py → ✅
```

---

## 📦 Como instalar

### 🐧 Linux — wget/tar (Usado na pipeline)
```bash
# Define versão
GITLEAKS_VERSION="8.24.2"

# Baixa o binário
wget "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
  -O /tmp/gitleaks.tar.gz

# Extrai
tar -xzf /tmp/gitleaks.tar.gz -C /tmp/

# Instala em PATH
sudo mv /tmp/gitleaks /usr/local/bin/gitleaks
sudo chmod +x /usr/local/bin/gitleaks

# Verifica
gitleaks version
```

### 🪟 Windows — PowerShell
```powershell
# Opção 1: Download direto (PowerShell)
$VERSION = "8.24.2"
$URL = "https://github.com/gitleaks/gitleaks/releases/download/v$VERSION/gitleaks_${VERSION}_windows_x64.zip"
Invoke-WebRequest -Uri $URL -OutFile "$env:TEMP\gitleaks.zip"
Expand-Archive -Path "$env:TEMP\gitleaks.zip" -DestinationPath "$env:TEMP\gitleaks"
Move-Item "$env:TEMP\gitleaks\gitleaks.exe" "C:\Windows\System32\gitleaks.exe"
gitleaks version
```

```powershell
# Opção 2: Chocolatey
choco install gitleaks
```

```powershell
# Opção 3: Winget
winget install gitleaks.gitleaks
```

### 🍎 macOS — Homebrew
```bash
brew install gitleaks
```

### 🐳 Docker (todas as plataformas)
```bash
# Linux/macOS — analisa histórico Git
docker run --rm \
  -v "$(pwd):/repo" \
  zricethezav/gitleaks:latest \
  git /repo --verbose

# Linux/macOS — analisa diretório sem histórico Git
docker run --rm \
  -v "$(pwd):/repo" \
  zricethezav/gitleaks:latest \
  dir /repo

# Linux/macOS — com configuração customizada
docker run --rm \
  -v "$(pwd):/repo" \
  -v "$(pwd)/.gitleaks.toml:/config/.gitleaks.toml" \
  zricethezav/gitleaks:latest \
  git /repo --config /config/.gitleaks.toml
```

```powershell
# Windows PowerShell
docker run --rm `
  -v "${PWD}:/repo" `
  zricethezav/gitleaks:latest `
  git /repo --verbose
```

### 🔧 Go (todas as plataformas)
```bash
# Requere Go 1.21+
go install github.com/gitleaks/gitleaks/v8@latest
```

### 💾 Binários pré-compilados
Acesse: [https://github.com/gitleaks/gitleaks/releases](https://github.com/gitleaks/gitleaks/releases)

| Plataforma | Arquivo |
|---|---|
| Linux x64 | `gitleaks_X.Y.Z_linux_x64.tar.gz` |
| Linux ARM64 | `gitleaks_X.Y.Z_linux_arm64.tar.gz` |
| Windows x64 | `gitleaks_X.Y.Z_windows_x64.zip` |
| macOS x64 | `gitleaks_X.Y.Z_darwin_x64.tar.gz` |
| macOS ARM64 | `gitleaks_X.Y.Z_darwin_arm64.tar.gz` |

---

## 🛠️ Comandos principais

### Estrutura básica
```
gitleaks <subcomando> [flags] [caminho]
```

### Comandos essenciais

```bash
# ---- SUBCOMANDO: git (histórico Git) ----

# Escanear histórico do repositório atual
gitleaks git --verbose

# Escanear repositório específico
gitleaks git /caminho/para/repo --verbose

# Verificar apenas staged files (pre-commit hook)
gitleaks git --staged --verbose

# Verificar intervalo de commits
gitleaks git --log-opts="abc123..def456"

# Gerar relatório JSON
gitleaks git . \
  --report-format json \
  --report-path gitleaks-report.json

# Gerar relatório SARIF (compatível com GitHub Security tab)
gitleaks git . \
  --report-format sarif \
  --report-path gitleaks-report.sarif

# Scan com baseline (ignora findings já conhecidos)
gitleaks git . \
  --baseline-path baseline.json \
  --report-path new-findings.json

# Habilitar scan dentro de arquivos compactados
gitleaks git . --max-archive-depth 3

# Habilitar detecção de segredos codificados (base64, hex)
gitleaks git . --max-decode-depth 2

# ---- SUBCOMANDO: dir (filesystem) ----

# Escanear diretório atual
gitleaks dir --verbose

# Escanear diretório específico
gitleaks dir examples/secrets/ --verbose

# Escanear arquivo único
gitleaks dir examples/secrets/vulnerable-sample.env

# Seguir symlinks
gitleaks dir --follow-symlinks /caminho/

# Gerar relatório SARIF
gitleaks dir . \
  --report-path results.sarif \
  --report-format sarif

# Redigir segredos no output (50% redact)
gitleaks dir --redact=50 --verbose

# ---- SUBCOMANDO: stdin ----

# Pipar conteúdo para verificação
cat suspicious.txt | gitleaks stdin --verbose
echo 'AWS_KEY=AKIAIOSFODNN7EXAMPLE' | gitleaks stdin

# Usar arquivo de configuração customizado
gitleaks git . --config .gitleaks.toml
```

### Opções de output:

| Flag | Descrição |
|------|-----------|
| `--report-format` | Formato: `json`, `csv`, `sarif`, `junit` |
| `--report-path` | Caminho do arquivo de relatório |
| `--verbose` | Mostra detalhes de cada finding |
| `--redact` | Redige parte do segredo no output (e.g. `--redact=50`) |
| `--no-color` | Desabilita cores no output |
| `--exit-code` | Código de saída quando encontra segredos (padrão: 1) |
| `--max-archive-depth` | Profundidade máxima para scan de zips/tars aninhados |
| `--max-decode-depth` | Profundidade para decodificar base64/hex antes de escanear |

---

## ⚙️ Configuração customizada

### Arquivo `.gitleaks.toml`

```toml
# .gitleaks.toml — Configuração customizada do Gitleaks

title = "Configuração Gitleaks - CaioDevSecOps"

[extend]
# Herda regras padrão
useDefault = true

# ============================================
# ALLOW LIST GLOBAL (ignora em todo o repo)
# ============================================
[allowlist]
description = "Exceções globais"
paths = [
  # Ignora arquivos de exemplo/teste propositalmente vulneráveis
  '''examples/secrets/vulnerable-sample\.env''',
  # Ignora documentação com exemplos
  '''docs/.*\.md''',
  # Ignora arquivos de fixture de teste
  '''tests/fixtures/.*''',
]
regexes = [
  # Ignora valores de placeholder óbvios
  '''EXAMPLE''',
  '''your[-_]?api[-_]?key[-_]?here''',
  '''<YOUR[-_]TOKEN>''',
]

# ============================================
# REGRAS CUSTOMIZADAS
# ============================================

# Detectar tokens customizados da empresa
[[rules]]
id = "custom-internal-token"
description = "Token interno da empresa"
regex = '''MYAPP_TOKEN_[A-Z0-9]{32}'''
tags = ["internal", "token"]

  [rules.allowlist]
  description = "Ignora tokens em testes"
  paths = ['''tests/.*''']

# Detectar credenciais de banco específicas
[[rules]]
id = "custom-db-credentials"
description = "URL de banco de dados com credenciais"
regex = '''(mysql|postgres|mongodb):\/\/[^:]+:[^@]+@[^\/]+'''
tags = ["database", "credentials"]
```

### Como verificar se a configuração está correta:
```bash
# Valida o arquivo de configuração
gitleaks git . --config .gitleaks.toml --verbose
```

---

## 🪝 Como usar em pre-commit

### Opção 1: Hook Git manual
```bash
# Cria o script de pre-commit
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🔍 Verificando segredos com Gitleaks..."

# Verifica se gitleaks está instalado
if ! command -v gitleaks &> /dev/null; then
    echo "⚠️  Gitleaks não encontrado. Instale: https://github.com/gitleaks/gitleaks"
    exit 0
fi

# Executa verificação de staged files (novo subcomando: git --staged)
gitleaks git --staged --verbose

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ COMMIT BLOQUEADO: Segredos detectados!"
    echo "   Remova os segredos antes de commitar."
    echo "   Use variáveis de ambiente para credenciais."
    exit 1
fi

echo "✅ Nenhum segredo detectado. Prosseguindo com o commit."
EOF

# Torna executável
chmod +x .git/hooks/pre-commit
```

### Opção 2: Framework pre-commit (recomendado)
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4
    hooks:
      - id: gitleaks
        name: Detectar segredos com Gitleaks
        description: Verifica staged files por segredos antes do commit
        entry: gitleaks git --staged --verbose
        language: golang
        pass_filenames: false
```

```bash
# Instala o pre-commit framework
pip install pre-commit

# Instala os hooks
pre-commit install

# Testa manualmente
pre-commit run gitleaks
```

---

## 📖 Exemplos práticos

### Exemplo 1: Auditoria de repositório existente
```bash
# Clona e audita um repositório
git clone https://github.com/minha-org/meu-repo.git
cd meu-repo

# Verifica histórico completo
gitleaks git . \
  --report-format json \
  --report-path audit-report.json \
  --verbose

# Conta quantos segredos foram encontrados
cat audit-report.json | python3 -c "import json,sys; data=json.load(sys.stdin); print(f'Total: {len(data)} segredos encontrados')"
```

### Exemplo 2: Integração em pipeline CI (apenas diff do PR)
```bash
# Na pipeline, analisa apenas commits novos
gitleaks git . \
  --log-opts="origin/main..HEAD" \
  --report-format sarif \
  --report-path gitleaks-results.sarif \
  --verbose || true
```

### Exemplo 3: Scan de diretório de segredos
```bash
# Analisa diretório sem histórico Git
gitleaks dir examples/secrets/ --verbose
```

### Exemplo 4: Criar e usar baseline
```bash
# Gera baseline do estado atual (ignora findings já conhecidos)
gitleaks git . --report-path baseline.json --report-format json
git add baseline.json
git commit -m "Add gitleaks baseline"

# Scans futuros só reportam NOVOS segredos
gitleaks git . \
  --baseline-path baseline.json \
  --report-path new-findings.json
```

### Lendo o relatório JSON:
```json
[
  {
    "Description": "AWS Access Token",
    "StartLine": 12,
    "EndLine": 12,
    "StartColumn": 20,
    "EndColumn": 40,
    "Match": "AKIAIOSFODNN7EXAMPLE",
    "Secret": "AKIAIOSFODNN7EXAMPLE",
    "File": "examples/secrets/vulnerable-sample.env",
    "SymlinkFile": "",
    "Commit": "abc123...",
    "Entropy": 3.5,
    "Author": "Developer",
    "Email": "dev@example.com",
    "Date": "2024-01-01T00:00:00Z",
    "Message": "Add config",
    "Tags": ["aws", "access-token"]
  }
]
```

---

## 🔗 Links úteis

| Recurso | URL |
|---------|-----|
| Repositório GitHub | [https://github.com/gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) |
| Releases (binários) | [https://github.com/gitleaks/gitleaks/releases](https://github.com/gitleaks/gitleaks/releases) |
| Documentação de regras | [https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml](https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml) |
| pre-commit hooks | [https://pre-commit.com/](https://pre-commit.com/) |
| Gitleaks Docs | [https://gitleaks.io/](https://gitleaks.io/) |

---

> **Dica pro**: Execute `gitleaks dir .` regularmente em seus projetos para verificar arquivos que possam conter segredos, independente do histórico Git. Use `gitleaks git . --max-decode-depth 2` para detectar segredos codificados em base64 ou hex!
