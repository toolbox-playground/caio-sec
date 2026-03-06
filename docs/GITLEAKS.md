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

## 🔄 Detect vs Protect

O Gitleaks possui dois modos principais de operação:

### 🔍 `detect` — Análise retrospectiva
```bash
gitleaks detect --source .
```
- Analisa **commits já existentes** no histórico
- Útil para **auditoria** de repositórios existentes
- Ideal para CI/CD para verificar código já commitado

### 🛡️ `protect` — Proteção proativa
```bash
gitleaks protect --staged
```
- Verifica apenas o **índice Git (staged files)**
- Usado em **pre-commit hooks** para interceptar antes do commit
- Previne que segredos entrem no histórico

### Diferença visual:

```
DETECT: Analisa histórico completo
  commit 1 → ✅
  commit 2 → ✅
  commit 3 → ❌ SEGREDO ENCONTRADO!
  commit 4 → ✅
  (todos os commits são verificados)

PROTECT: Intercepta antes do commit
  git add secret.txt
  git commit → BLOCKED! ❌ Segredo detectado
  (commit nunca entra no histórico)
```

---

## 📦 Como instalar

### Método 1: wget/tar (Linux/macOS) — Usado na pipeline
```bash
# Define versão
GITLEAKS_VERSION="8.18.4"

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

### Método 2: Homebrew (macOS)
```bash
brew install gitleaks
```

### Método 3: Docker
```bash
# Analisa diretório atual
docker run --rm \
  -v "$(pwd):/repo" \
  zricethezav/gitleaks:latest \
  detect --source /repo
```

### Método 4: Go
```bash
# Requere Go 1.21+
go install github.com/gitleaks/gitleaks/v8@latest
```

### Método 5: Binários pré-compilados
Acesse: [https://github.com/gitleaks/gitleaks/releases](https://github.com/gitleaks/gitleaks/releases)

---

## 🛠️ Comandos principais

### Estrutura básica
```
gitleaks <comando> [flags] --source <caminho>
```

### Comandos essenciais

```bash
# Detectar segredos no histórico Git completo
gitleaks detect --source .

# Detectar em modo verbose (mostra todos os detalhes)
gitleaks detect --source . --verbose

# Detectar em arquivos não-commitados (sem histórico Git)
gitleaks detect --source . --no-git

# Proteger (verificar staged files)
gitleaks protect --staged

# Gerar relatório JSON
gitleaks detect --source . \
  --report-format json \
  --report-path gitleaks-report.json

# Gerar relatório SARIF
gitleaks detect --source . \
  --report-format sarif \
  --report-path gitleaks-report.sarif

# Usar arquivo de configuração customizado
gitleaks detect --source . \
  --config .gitleaks.toml

# Especificar branch específica
gitleaks detect --source . \
  --log-opts="--branches main develop"

# Verificar apenas últimos N commits
gitleaks detect --source . \
  --log-opts="-n 50"
```

### Opções de output:

| Flag | Descrição |
|------|-----------|
| `--report-format` | Formato: `json`, `csv`, `sarif`, `junit` |
| `--report-path` | Caminho do arquivo de relatório |
| `--verbose` | Mostra detalhes de cada finding |
| `--no-color` | Desabilita cores no output |
| `--exit-code` | Código de saída quando encontra segredos (padrão: 1) |

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
gitleaks detect --source . --config .gitleaks.toml --verbose
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

# Executa verificação de staged files
gitleaks protect --staged --verbose

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
        entry: gitleaks protect --staged --verbose
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
gitleaks detect --source . \
  --report-format json \
  --report-path audit-report.json \
  --verbose

# Conta quantos segredos foram encontrados
cat audit-report.json | python3 -c "import json,sys; data=json.load(sys.stdin); print(f'Total: {len(data)} segredos encontrados')"
```

### Exemplo 2: Integração em pipeline CI
```bash
# Na pipeline, analisa apenas mudanças do PR
gitleaks detect \
  --source . \
  --log-opts="origin/main..HEAD" \
  --report-format sarif \
  --report-path gitleaks-results.sarif \
  --verbose || true
```

### Exemplo 3: Scan de arquivo específico
```bash
# Analisa sem considerar histórico Git
gitleaks detect \
  --source examples/secrets/ \
  --no-git \
  --verbose
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

> **Dica pro**: Execute `gitleaks detect --source . --no-git` regularmente em seus projetos mesmo sem histórico Git para verificar arquivos que podem ter sido adicionados sem passar pelo git!
