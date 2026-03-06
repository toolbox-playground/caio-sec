# 🐷 TruffleHog - Guia Completo

> Caça a segredos com verificação ativa e análise de entropia

---

## 📋 Índice

- [O que é TruffleHog?](#o-que-é-trufflehog)
- [Como funciona?](#como-funciona)
- [Como instalar](#como-instalar)
- [Comandos principais](#comandos-principais)
- [Modos de operação](#modos-de-operação)
- [Verificação customizada](#verificação-customizada)
- [Exemplos de uso](#exemplos-de-uso)
- [TruffleHog vs Gitleaks](#trufflehog-vs-gitleaks)
- [Links úteis](#links-úteis)

---

## 🔍 O que é TruffleHog?

**TruffleHog** é uma ferramenta open-source desenvolvida pela **Truffle Security** para detectar segredos e credenciais em repositórios Git, buckets de armazenamento, e sistemas de arquivos. O diferencial do TruffleHog é a capacidade de **verificar ativamente** se os segredos encontrados são válidos.

### Destaques:
- 🔬 **Verificação ativa**: Testa se tokens/keys estão realmente ativos
- 📡 **Múltiplas fontes**: Git, GitHub, S3, GCS, filesystem, Syslog
- 🧠 **800+ detectores**: Um detector específico para cada provider
- 📊 **Alta precisão**: Menos falsos positivos que ferramentas baseadas apenas em regex
- ⚡ **Paralelismo**: Scan rápido com múltiplas goroutines

---

## ⚙️ Como funciona?

O TruffleHog usa duas técnicas combinadas:

### 1. Detectores por Provider (Verificação Ativa)
Para cada tipo de credencial, o TruffleHog possui um detector específico que:
1. Identifica padrões que parecem ser aquele tipo de credencial
2. **Faz uma chamada real à API** para verificar se é válida
3. Reporta apenas credenciais **verificadas** (opcional)

```
Texto encontrado: "AKIA..." (parece AWS key)
       ↓
TruffleHog chama AWS STS API
       ↓
AWS responde: "Token válido" ou "Token inválido"
       ↓
Reportado como "VERIFIED" ou "UNVERIFIED"
```

### 2. Análise de Entropia
Para padrões desconhecidos, usa entropia de Shannon para identificar strings que são "aleatórias demais" para serem texto normal:

$$H = -\sum_{i=1}^{n} p_i \log_2 p_i$$

- **Baixa entropia**: `hello_world` → provavelmente texto normal
- **Alta entropia**: `x7Kp9mNq2rTs4Wv6` → provavelmente um segredo

---

## 📦 Como instalar

### 🐧 Linux — Script oficial (Usado na pipeline)
```bash
# Instala o binário mais recente
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh \
  | sudo sh -s -- -b /usr/local/bin

# Versão específica
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh \
  | sudo sh -s -- -b /usr/local/bin v3.88.0

# Verifica
trufflehog --version
```

### 🧳 Windows — PowerShell
```powershell
# Opção 1: Download direto (PowerShell)
$VERSION = "3.88.0"
$URL = "https://github.com/trufflesecurity/trufflehog/releases/download/v$VERSION/trufflehog_${VERSION}_windows_amd64.zip"
Invoke-WebRequest -Uri $URL -OutFile "$env:TEMP\trufflehog.zip"
Expand-Archive -Path "$env:TEMP\trufflehog.zip" -DestinationPath "$env:TEMP\trufflehog"
Move-Item "$env:TEMP\trufflehog\trufflehog.exe" "C:\Windows\System32\trufflehog.exe"
trufflehog --version
```

```bash
# Opção 2: WSL (Windows Subsystem for Linux)
# O script de instalação também funciona no WSL:
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh \
  | sh -s -- -b /usr/local/bin
```

### 🍎 macOS — Homebrew
```bash
brew install trufflehog
```

### 🐳 Docker (todas as plataformas)
```bash
# Linux/macOS — scan de repositório Git
docker run --rm \
  trufflesecurity/trufflehog:latest \
  git https://github.com/minha-org/meu-repo.git

# Linux/macOS — scan de filesystem local
docker run --rm \
  -v "$(pwd):/repo" \
  trufflesecurity/trufflehog:latest \
  filesystem /repo
```

```powershell
# Windows PowerShell
docker run --rm -it `
  -v "${PWD}:/pwd" `
  trufflesecurity/trufflehog:latest `
  git file:///pwd --results=verified,unknown
```

### 🔧 Go (todas as plataformas)
```bash
# Requere Go 1.21+
go install github.com/trufflesecurity/trufflehog/v3@latest
```

### 💾 Binários pré-compilados
Acesse: [https://github.com/trufflesecurity/trufflehog/releases](https://github.com/trufflesecurity/trufflehog/releases)

| Plataforma | Arquivo |
|---|---|
| Linux x64 | `trufflehog_X.Y.Z_linux_amd64.tar.gz` |
| Linux ARM64 | `trufflehog_X.Y.Z_linux_arm64.tar.gz` |
| Windows x64 | `trufflehog_X.Y.Z_windows_amd64.zip` |
| macOS x64 | `trufflehog_X.Y.Z_darwin_amd64.tar.gz` |
| macOS ARM64 | `trufflehog_X.Y.Z_darwin_arm64.tar.gz` |

---

## 🛠️ Comandos principais

### Estrutura básica
```
trufflehog <fonte> [flags]
```

### Comandos por fonte

```bash
# ---- FILESYSTEM ----
# Analisa sistema de arquivos local (path é argumento posicional)
trufflehog filesystem /path/to/dir

# Com output JSON e sem auto-update (recomendado em CI)
trufflehog filesystem . --json --no-update

# Apenas segredos verificados (válidos)
trufflehog filesystem . --results=verified

# ---- GIT ----
# Analisa histórico Git local
trufflehog git file:///path/to/repo

# Analisa repositório remoto
trufflehog git https://github.com/org/repo.git

# Com credenciais (repo privado)
trufflehog git https://github.com/org/private-repo.git \
  --token=ghp_your_github_token

# ---- GITHUB ----
# Analisa todos os repos de uma organização
trufflehog github --org=minha-organizacao \
  --token=ghp_your_github_token

# Analisa usuário específico
trufflehog github --user=meu-usuario \
  --token=ghp_your_github_token

# Inclui issues e PRs no scan
trufflehog github --org=minha-organizacao \
  --token=ghp_your_github_token \
  --issue-comments \
  --pr-comments

# ---- S3 ----
# Analisa bucket S3
trufflehog s3 --bucket=meu-bucket

# ---- SYSLOG ----
# Analisa syslog em tempo real
trufflehog syslog --address=0.0.0.0:514 --protocol=tcp
```

### Flags globais importantes:

| Flag | Descrição |
|------|-----------|
| `--json` | Output em formato JSON |
| `--results` | Filtra por: `verified`, `unknown`, `unverified`, `filtered_unverified` |
| `--no-verification` | Não verifica ativamente (mais rápido) |
| `--no-update` | Não verifica novas versões (essencial em CI) |
| `--concurrency` | Número de workers paralelos (padrão: 8) |
| `--include-detectors` | Lista de detectores a usar |
| `--exclude-detectors` | Lista de detectores a ignorar |

---

## 🎯 Modos de operação

### Modo verificado (padrão em produção)
```bash
trufflehog git https://github.com/org/repo.git \
  --results=verified \
  --json
```
- Reporta apenas credenciais **ATIVAS** (testadas e válidas)
- **Menor número de falsos positivos**
- Mais devagar (faz chamadas de API)

### Modo não-verificado (mais rápido)
```bash
trufflehog filesystem . \
  --no-verification \
  --json \
  --no-update
```
- Reporta todos os padrões que **parecem** credenciais
- **Mais rápido** (sem chamadas de API)
- Pode ter mais falsos positivos

### Modo "all results" (usado na pipeline)
```bash
trufflehog filesystem . \
  --results=verified,unknown,unverified \
  --json \
  --no-update
```

---

## 🔧 Verificação customizada

### Criando detector customizado (arquivo de configuração)
```yaml
# custom-detectors.yaml
detectors:
  - name: MyCustomToken
    keywords:
      - myapp_token
    regex:
      sensitive: MYAPP_TOKEN_[A-Z0-9]{32}
    verify:
      - endpoint: https://api.minha-empresa.com/validate
        response:
          failure:
            - match: '"valid":false'
```

```bash
# Usando detector customizado
trufflehog filesystem --directory . \
  --config=custom-detectors.yaml
```

### Ignorando paths com arquivo de exclusão
```bash
# TruffleHog respeita .gitignore por padrão
# Para ignorar caminhos específicos:
trufflehog filesystem --directory . \
  --exclude-paths=trufflehog-exclude.txt
```

```
# trufflehog-exclude.txt
examples/secrets/vulnerable-sample.env
docs/
tests/fixtures/
```

---

## 📖 Exemplos de uso

### Exemplo 1: Scan rápido do projeto atual
```bash
# Scan rápido sem verificação ativa
trufflehog filesystem \
  . \
  --no-verification \
  --no-update \
  --json 2>&1 | head -100
```

### Exemplo 2: Verificando repositório remoto (GitHub)
```bash
# Analisa repo público (sem token)
trufflehog git https://github.com/usuario/repo.git \
  --no-verification \
  --json

# Analisa repo privado (com token)
trufflehog git https://github.com/org/private-repo.git \
  --token=${GITHUB_TOKEN} \
  --only-verified
```

### Exemplo 3: Audit completo de organização GitHub
```bash
# Varre TODOS os repos de uma organização
trufflehog github \
  --org=minha-organizacao \
  --token=${GITHUB_TOKEN} \
  --only-verified \
  --concurrency=10 \
  --json > org-audit-$(date +%Y%m%d).json

# Conta segredos encontrados por repositório
cat org-audit-*.json | \
  python3 -c "
import json, sys
from collections import Counter
findings = [json.loads(l) for l in sys.stdin if l.strip()]
repos = Counter(f.get('SourceMetadata', {}).get('Data', {}).get('Git', {}).get('repository', 'unknown') for f in findings)
for repo, count in repos.most_common(10):
    print(f'{count:3d} - {repo}')
"
```

### Exemplo 4: Integração em pipeline CI
```bash
# Na pipeline, verifica apenas diferenças do PR
trufflehog git \
  file://. \
  --since-commit=origin/main \
  --branch=HEAD \
  --only-verified \
  --json > trufflehog-results.json || true

# Verifica se encontrou algo
if [ -s trufflehog-results.json ]; then
  echo "❌ Segredos verificados encontrados!"
  cat trufflehog-results.json
  exit 1
fi
```

### Lendo output JSON:
```json
{
  "SourceMetadata": {
    "Data": {
      "Filesystem": {
        "file": "examples/secrets/vulnerable-sample.env",
        "line": 12
      }
    }
  },
  "SourceID": 1,
  "SourceType": 15,
  "SourceName": "trufflehog - filesystem",
  "DetectorType": 2,
  "DetectorName": "AWSKeyID",
  "DecoderName": "PLAIN",
  "Verified": false,
  "Raw": "AKIAIOSFODNN7EXAMPLE",
  "RawV2": "AKIAIOSFODNN7EXAMPLEwJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "Redacted": "AKIA************MPLE",
  "ExtraData": null,
  "StructuredData": null
}
```

---

## ⚖️ TruffleHog vs Gitleaks

| Característica | TruffleHog | Gitleaks |
|----------------|------------|----------|
| **Verificação ativa** | ✅ Sim (800+ provedores) | ❌ Não |
| **Velocidade** | Moderada | ⚡ Muito rápida |
| **Pre-commit hook** | ✅ Suportado | ✅ Suportado |
| **Análise de entropia** | ✅ Sim | ✅ Sim |
| **Configuração customizada** | Moderada | ✅ Muito flexível |
| **Fontes suportadas** | Git, S3, GCS, GitHub, GitLab... | Git, filesystem |
| **Linguagem** | Go | Go |
| **Falsos positivos** | ⬇️ Mais baixo (verificação) | Médio |
| **Uso ideal** | Auditoria de segurança | CI/CD rápido, pre-commit |

**Recomendação**: Use **ambas** as ferramentas! Gitleaks no pre-commit (rápido) + TruffleHog na pipeline de CI com verificação ativa.

---

## 🔗 Links úteis

| Recurso | URL |
|---------|-----|
| Repositório GitHub | [https://github.com/trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog) |
| Documentação oficial | [https://trufflesecurity.com/trufflehog](https://trufflesecurity.com/trufflehog) |
| Lista de detectores | [https://github.com/trufflesecurity/trufflehog/tree/main/pkg/detectors](https://github.com/trufflesecurity/trufflehog/tree/main/pkg/detectors) |
| Releases | [https://github.com/trufflesecurity/trufflehog/releases](https://github.com/trufflesecurity/trufflehog/releases) |
| Truffle Security Blog | [https://trufflesecurity.com/blog](https://trufflesecurity.com/blog) |

---

> **Dica pro**: Use `--only-verified` em ambientes de produção para reduzir drasticamente os falsos positivos e focar apenas em credenciais **ativamente exploráveis**!
