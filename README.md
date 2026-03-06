<div align="center">

# 🔒 CaioDevSecOps

### Pipeline de Segurança Unificada para DevSecOps

[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/toolbox-playground/CaioDevSecOps/unified-security-pipeline.yaml?branch=main&label=Security%20Pipeline&logo=github-actions&logoColor=white&style=for-the-badge)](https://github.com/toolbox-playground/CaioDevSecOps/actions)
[![Checkov](https://img.shields.io/badge/Checkov-IaC%20Security-0080FF?style=for-the-badge&logo=python&logoColor=white)](https://www.checkov.io/)
[![Gitleaks](https://img.shields.io/badge/Gitleaks-Secret%20Detection-E63946?style=for-the-badge&logo=git&logoColor=white)](https://github.com/gitleaks/gitleaks)
[![TruffleHog](https://img.shields.io/badge/TruffleHog-Secret%20Hunter-FF6B35?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0tMSAxNEg5VjhoMnY4em00IDBoLTJWOGgydjh6Ii8+PC9zdmc+)](https://trufflesecurity.com/trufflehog)
[![Trivy](https://img.shields.io/badge/Trivy-Vulnerability%20Scanner-1DB954?style=for-the-badge&logo=aqua&logoColor=white)](https://aquasecurity.github.io/trivy/)
[![Snyk](https://img.shields.io/badge/Snyk-Code%20Security-4C4A73?style=for-the-badge&logo=snyk&logoColor=white)](https://snyk.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-F7C948?style=for-the-badge)](LICENSE.md)
[![Toolbox](https://img.shields.io/badge/By-Toolbox%20Playground-0A0A0A?style=for-the-badge&logo=github)](https://github.com/toolbox-playground)

---

**Um repositório educacional completo com pipeline de segurança integrada,**  
**exemplos vulneráveis intencionais e documentação detalhada para todos os níveis.**

> 🗓️ Atualizado em Março de 2026 • Ferramentas verificadas via [Context7](https://context7.com)

[🚀 Quick Start](#-quick-start) •
[🛠️ Ferramentas](#️-ferramentas-incluídas) •
[📁 Estrutura](#-estrutura-do-projeto) •
[🎯 Como Usar](#-como-usar) •
[📖 Docs](#-documentação-detalhada)

</div>

---

## 📋 Índice

- [✨ Features](#-features)
- [🚀 Quick Start](#-quick-start)
- [🛠️ Ferramentas Incluídas](#️-ferramentas-incluídas)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [🔧 Configuração](#-configuração)
- [🎯 Como Usar](#-como-usar)
- [📖 Documentação Detalhada](#-documentação-detalhada)
- [🧪 Exemplos de Vulnerabilidades](#-exemplos-de-vulnerabilidades)
- [📊 Resultados Esperados](#-resultados-esperados)
- [🔍 Troubleshooting](#-troubleshooting)
- [👥 Para Todos os Níveis](#-para-todos-os-níveis)
- [🤝 Contribuindo](#-contribuindo)
- [🔗 Links Úteis](#-links-úteis)
- [⚠️ Avisos Importantes](#️-avisos-importantes)
- [📝 Licença](#-licença)

---

## ✨ Features

| Feature | Descrição |
|---------|-----------|
| 🔒 **5 Ferramentas Integradas** | Checkov, Gitleaks, TruffleHog, Trivy e Snyk em uma pipeline |
| 🔧 **Instalação Manual** | Cada ferramenta instalada manualmente via pip, wget, curl, apt, npm |
| 🐛 **Exemplos Vulneráveis** | Código Python, Dockerfile e Terraform com vulnerabilidades intencionais |
| 📚 **Documentação Completa** | Guias detalhados para cada ferramenta |
| 🎓 **Didático** | Comentários em português explicando cada vulnerabilidade |
| 📊 **Relatórios Automáticos** | Artefatos gerados e salvos a cada execução da pipeline |
| ⚡ **Jobs Paralelos** | Cada ferramenta executa em seu próprio job independente |
| 🛡️ **continue-on-error** | Pipeline não bloqueia — foco em aprendizado |

---

## 🚀 Quick Start

### Pré-requisitos
- Conta no GitHub
- (Opcional) Conta no [Snyk.io](https://app.snyk.io/) para o scan Snyk

### Passo a passo:

**1. Faça fork ou clone do repositório**
```bash
git clone https://github.com/toolbox-playground/CaioDevSecOps.git
cd CaioDevSecOps
```

**2. (Opcional) Configure o secret do Snyk**
```
1. Acesse https://app.snyk.io/account e copie seu token
2. No GitHub: Settings → Secrets and variables → Actions
3. Clique em "New repository secret"
4. Nome: SNYK_TOKEN | Valor: seu-token
```

**3. Execute a pipeline**
```
Opção A (automático): Faça um push para a branch main
Opção B (manual): Actions → "Pipeline de Segurança Unificada" → "Run workflow"
```

**4. Acesse os resultados**
```
1. Clique em "Actions" no repositório
2. Selecione a execução mais recente
3. Veja cada job individualmente
4. Baixe os "Artifacts" com os relatórios completos
```

---

## 🛠️ Ferramentas Incluídas

| # | Ferramenta | Tipo de Análise | Instalação | Versão | Docs |
|---|------------|-----------------|------------|--------|------|
| 1 | 🏗️ **Checkov** | Análise estática de IaC (Terraform, Dockerfile, K8s) | `pip3 install checkov` | [![PyPI](https://img.shields.io/pypi/v/checkov?label=&color=blue)](https://pypi.org/project/checkov/) | [CHECKOV.md](docs/CHECKOV.md) |
| 2 | 🔑 **Gitleaks** | Detecção de segredos no histórico Git e filesystem | `wget` + `tar` (binário) | [![GitHub release](https://img.shields.io/github/v/release/gitleaks/gitleaks?label=&color=red)](https://github.com/gitleaks/gitleaks/releases) | [GITLEAKS.md](docs/GITLEAKS.md) |
| 3 | 🐷 **TruffleHog** | Caça a segredos com verificação ativa em 800+ fontes | `curl` script oficial | [![GitHub release](https://img.shields.io/github/v/release/trufflesecurity/trufflehog?label=&color=orange)](https://github.com/trufflesecurity/trufflehog/releases) | [TRUFFLEHOG.md](docs/TRUFFLEHOG.md) |
| 4 | 🛡️ **Trivy** | Scanner de vulnerabilidades: containers, FS, IaC, SBOM | `curl` script oficial | [![GitHub release](https://img.shields.io/github/v/release/aquasecurity/trivy?label=&color=green)](https://github.com/aquasecurity/trivy/releases) | [TRIVY.md](docs/TRIVY.md) |
| 5 | 🐍 **Snyk** | SAST, deps, containers e IaC com remediação automática | `npm install -g snyk` | [![npm](https://img.shields.io/npm/v/snyk?label=&color=purple)](https://www.npmjs.com/package/snyk) | [SNYK.md](docs/SNYK.md) |

---

## 📁 Estrutura do Projeto

```
CaioDevSecOps/
│
├── .github/
│   └── workflows/
│       └── unified-security-pipeline.yaml  ← Pipeline principal com 5 ferramentas
│
├── examples/
│   ├── python/
│   │   ├── app.py              ← Flask com SQL Injection, segredos hardcoded
│   │   ├── Dockerfile          ← Container com múltiplas vulnerabilidades
│   │   └── requirements.txt    ← Dependências desatualizadas com CVEs
│   │
│   ├── terraform/
│   │   └── main.tf             ← S3 público, Security Group aberto, RDS sem crypto
│   │
│   └── secrets/
│       └── vulnerable-sample.env  ← Segredos FALSOS para testar detecção
│
├── docs/
│   ├── CHECKOV.md              ← Guia completo: instalação, comandos, exemplos
│   ├── GITLEAKS.md             ← Guia completo: detect vs protect, configuração
│   ├── TRUFFLEHOG.md           ← Guia completo: entropia, verificação ativa
│   ├── TRIVY.md                ← Guia completo: imagens, filesystem, IaC
│   └── SNYK.md                 ← Guia completo: token, comandos, integração
│
├── README.md                   ← Este arquivo
├── CONTRIBUTING.md             ← Como contribuir com o projeto
├── LICENSE.md                  ← Licença MIT
└── .gitignore                  ← Ignora arquivos sensíveis e de build
```

---

## 🔧 Configuração

### Secrets necessários

| Secret | Obrigatório | Descrição | Como obter |
|--------|-------------|-----------|------------|
| `SNYK_TOKEN` | Opcional | Token de autenticação do Snyk | [https://app.snyk.io/account](https://app.snyk.io/account) |

> **Nota**: Checkov, Gitleaks, TruffleHog e Trivy funcionam **sem nenhuma configuração adicional**. Apenas o Snyk requer um token.

### Variáveis de ambiente da pipeline

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `SNYK_ENABLED` | `""` | Se `true`, habilita Snyk mesmo sem input manual |

### Configuração de branches

Por padrão, a pipeline executa em:
- Push para `main`
- Pull Requests para `main`
- Execução manual (`workflow_dispatch`)

Para mudar, edite o `.github/workflows/unified-security-pipeline.yaml`:
```yaml
on:
  push:
    branches:
      - main
      - develop    # Adicione branches aqui
```

---

## 🎯 Como Usar

### Executar localmente — Cada ferramenta individualmente

#### 1. Checkov
```bash
# Instala (pip3 recomendado)
pip3 install checkov

# Verifica instalação
checkov --version

# Scan de Terraform
checkov --directory examples/terraform --soft-fail

# Scan de Dockerfile
checkov --file examples/python/Dockerfile --framework dockerfile --soft-fail

# Scan com output SARIF (compatível com GitHub Security tab)
checkov --directory examples/terraform --output sarif --output-file-path results.sarif
```

#### 2. Gitleaks
```bash
# Instala (Linux) — binário estático, sem dependências
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.4/gitleaks_8.18.4_linux_x64.tar.gz -O /tmp/gitleaks.tar.gz
tar -xzf /tmp/gitleaks.tar.gz -C /tmp/
sudo mv /tmp/gitleaks /usr/local/bin/

# macOS
brew install gitleaks

# Verifica instalação
gitleaks version

# Detecta segredos no histórico Git (novo CLI: subcomando 'git')
gitleaks git . --verbose

# Detecta em diretório sem histórico Git (novo CLI: subcomando 'dir')
gitleaks dir examples/secrets/ --verbose

# Gera relatório JSON
gitleaks git . --report-path gitleaks-report.json --report-format json
```

#### 3. TruffleHog
```bash
# Instala
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sudo sh -s -- -b /usr/local/bin

# Scan do filesystem
trufflehog filesystem --directory . --no-verification --json

# Scan do Git
trufflehog git file://. --no-verification --json
```

#### 4. Trivy
```bash
# Instala via script oficial (recomendado — sempre instala a versão mais recente)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

# macOS via Homebrew
brew install aquasecurity/trivy/trivy

# Verifica instalação
trivy --version

# Constrói imagem de exemplo
docker build -t caio-example examples/python/

# Scan da imagem (somente CRITICAL e HIGH)
trivy image --severity CRITICAL,HIGH caio-example

# Scan de dependências Python
trivy filesystem --scanners vuln examples/python/

# Scan de IaC/Terraform
trivy config examples/terraform/

# Scan com output SARIF
trivy image --format sarif --output trivy-results.sarif caio-example
```

#### 5. Snyk
```bash
# Instala
npm install -g snyk

# Autentica (necessário)
snyk auth SEU_TOKEN_AQUI

# Scan de dependências
snyk test --file=examples/python/requirements.txt --package-manager=pip

# Scan de IaC
snyk iac test examples/terraform/

# Scan de container
docker build -t caio-example examples/python/
snyk container test caio-example --file=examples/python/Dockerfile
```

### Executar pipeline completa no GitHub

```
1. Acesse a aba "Actions" do repositório
2. Clique em "🔒 Pipeline de Segurança Unificada"
3. Clique em "Run workflow" (botão cinza/verde)
4. Selecione a branch (default: main)
5. Opcional: marque "Pular Snyk" se não tiver token
6. Clique em "Run workflow" para iniciar
```

---

## 📖 Documentação Detalhada

Cada ferramenta possui um guia completo na pasta `docs/`:

| Documento | Conteúdo |
|-----------|---------|
| 📄 [docs/CHECKOV.md](docs/CHECKOV.md) | IaC security, políticas CIS, configuração customizada |
| 📄 [docs/GITLEAKS.md](docs/GITLEAKS.md) | Detect vs Protect, pre-commit hooks, `.gitleaks.toml` |
| 📄 [docs/TRUFFLEHOG.md](docs/TRUFFLEHOG.md) | Verificação ativa, análise de entropia, múltiplas fontes |
| 📄 [docs/TRIVY.md](docs/TRIVY.md) | Containers, filesystem, IaC, severidades CVSS |
| 📄 [docs/SNYK.md](docs/SNYK.md) | Token, SAST, dependências, monitoramento contínuo |

---

## 🧪 Exemplos de Vulnerabilidades

> ⚠️ Todos os exemplos são **propositalmente vulneráveis** para fins didáticos.

### 📱 `examples/python/app.py`
| Vulnerabilidade | Tipo | Ferramenta que detecta |
|-----------------|------|----------------------|
| Segredos hardcoded (AWS, Stripe, API Keys) | Secret Exposure | Gitleaks, TruffleHog |
| SQL Injection (query com f-string) | OWASP A03 | Snyk Code |
| Criptografia fraca (MD5 para senhas) | CWE-327 | Snyk Code |
| Command Injection (`os.popen`) | OWASP A03 | Snyk Code |
| Debug mode em produção | Misconfiguration | Checkov, Snyk |

### 🐳 `examples/python/Dockerfile`
| Vulnerabilidade | Tipo | Ferramenta que detecta |
|-----------------|------|----------------------|
| Base image desatualizada (Python 3.8) | CVE exposure | Trivy, Checkov |
| Rodando como root | Privilege Escalation | Trivy, Checkov |
| Segredos no ENV | Secret Exposure | Trivy, Checkov |
| Sem HEALTHCHECK | Misconfiguration | Checkov |

### 🏗️ `examples/terraform/main.tf`
| Vulnerabilidade | Tipo | Ferramenta que detecta |
|-----------------|------|----------------------|
| Bucket S3 público (`public-read`) | Data Exposure | Checkov, Trivy, Snyk |
| S3 sem criptografia em repouso | CKV_AWS_19 | Checkov |
| Security Group com 0.0.0.0/0 porta 22 | Network Exposure | Checkov, Trivy, Snyk |
| RDS sem Multi-AZ e sem backup | Reliability | Checkov |
| IAM com permissões `*` | Privilege Escalation | Checkov |

### 🔐 `examples/secrets/vulnerable-sample.env`
| Segredo | Tipo | Ferramenta que detecta |
|---------|------|----------------------|
| `AKIAIOSFODNN7EXAMPLE` | AWS Access Key | Gitleaks, TruffleHog |
| `sk_live_...` | Stripe API Key | Gitleaks, TruffleHog |
| `ghp_...` | GitHub Personal Token | Gitleaks, TruffleHog |
| RSA Private Key | Cryptographic Key | Gitleaks, TruffleHog |

---

## 📊 Resultados Esperados

Ao executar a pipeline, você verá os seguintes resultados (aproximados):

| Ferramenta | Findings Esperados | Tipo |
|------------|-------------------|------|
| **Checkov** | ~15-20 falhas | Misconfigurations em Terraform e Dockerfile |
| **Gitleaks** | ~10-15 segredos | AWS keys, Stripe keys, GitHub tokens, Private key |
| **TruffleHog** | ~8-12 segredos | Stesso segredos, verificados como falsos |
| **Trivy** | ~30-50 CVEs | Vulnerabilidades em Python 3.8 e dependências |
| **Snyk** | ~5-10 vulnerabilidades | Dependências desatualizadas |

> **Todos os findings são ESPERADOS e INTENCIONAIS** — o objetivo é que as ferramentas encontrem esses problemas!

---

## 🔍 Troubleshooting

### ❌ "SNYK_TOKEN not configured"
```
Solução: Configure o secret SNYK_TOKEN nas configurações do repositório.
Settings → Secrets and variables → Actions → New repository secret
Nome: SNYK_TOKEN | Valor: seu-token-do-snyk
```

### ❌ "Docker build failed"
```bash
# Solução: O Dockerfile usa Python 3.8. Se a imagem não estiver disponível:
docker pull python:3.8
docker build -t caio-example examples/python/ --no-cache
```

### ❌ "Gitleaks: exit code 1"
```
INFO: Gitleaks retorna código 1 quando encontra segredos.
Isso é ESPERADO neste repositório (temos segredos de exemplo propositais).
O job usa continue-on-error: true para não bloquear o pipeline.
```

### ❌ "gitleaks: 'detect' is not a command" (CLI v8.18+)
```bash
# O subcomando 'detect' foi descontinuado — use os novos subcomandos:
# 'detect --source . '          → 'git .'           (para repos Git)
# 'detect --source dir --no-git' → 'dir .'          (para diretórios)
# 'protect'                      → 'git --pre-commit' (no pre-commit hook)
gitleaks git . --verbose
```

### ❌ "Checkov: Module not found"
```bash
# Solução: Certifique-se de ter Python 3.8+ e pip atualizado
python --version  # deve ser 3.8+
pip install --upgrade pip checkov
```

### ❌ "Trivy: database download failed"
```bash
# Solução: Atualiza o banco de CVEs manualmente
trivy image --download-db-only

# Ou usa cache de uma execução anterior
trivy image --cache-dir ~/.cache/trivy nginx:latest

# Alternativa: skip update e usa DB cacheado
trivy image --skip-db-update caio-example
```

### ❌ "TruffleHog: command not found"
```bash
# Solução: Reinstala via script oficial
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh \
  | sudo sh -s -- -b /usr/local/bin
which trufflehog
trufflehog --version
```

---

## 👥 Para Todos os Níveis

### 🟢 Iniciante — Começando do zero

Se você é novo em DevSecOps, siga este caminho:

1. **Entenda o que é segurança em código**: Leia a [introdução no README](#-exemplos-de-vulnerabilidades)
2. **Explore os exemplos vulneráveis**: Veja `examples/python/app.py` — os comentários explicam cada vulnerabilidade
3. **Execute a pipeline**: Siga o [Quick Start](#-quick-start) e veja os resultados
4. **Leia a documentação básica**:
   - Comece por [TRIVY.md](docs/TRIVY.md) (mais visual e fácil)
   - Depois [CHECKOV.md](docs/CHECKOV.md)
5. **Instale localmente**: Tente executar Trivy no seu máquina:
   ```bash
   # macOS
   brew install aquasecurity/trivy/trivy
   trivy filesystem .
   ```

### 🟡 Intermediário — Ampliando o conhecimento

Se você já conhece as ferramentas básicas:

1. **Customize a pipeline**: Adicione `--exit-code 1` para bloquear em CRITICAL
2. **Configure Gitleaks pre-commit**: Veja [GITLEAKS.md](docs/GITLEAKS.md#como-usar-em-pre-commit)
3. **Explore relatórios SARIF**: Integre com o GitHub Security tab
4. **Configure `.trivyignore`** e `.gitleaks.toml` para seus projetos reais
5. **Adicione Snyk monitoring**: Execute `snyk monitor` nos seus projetos de produção
6. **Crie checks customizados**: Veja a seção de config avançada em [CHECKOV.md](docs/CHECKOV.md)

### 🔴 Avançado — Dominando DevSecOps

Para profissionais experientes:

1. **Integre com SIEM**: Exporte relatórios para Splunk, Elastic, ou Datadog
2. **Policy as Code**: Crie políticas OPA/Rego para Checkov e deploy gates
3. **Threat Modeling**: Use os findings como insumo para STRIDE/PASTA
4. **Supply Chain Security**: Gere e verifique SBOMs com Trivy + sigstore/cosign
5. **Runtime Security**: Combine com Falco para detecção em tempo real
6. **Crie seu próprio scanner**: Contribua com detectores para Gitleaks/TruffleHog
7. **Automação de remediação**: Integre Snyk fix em auto-PRs via Dependabot

---

## 🤝 Contribuindo

Contribuições são muito bem-vindas! Veja o [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes.

Formas de contribuir:
- 🐛 Reportar bugs
- ✨ Sugerir novas features
- 📖 Melhorar a documentação
- 🔧 Adicionar novas ferramentas de segurança
- 🌍 Traduzir para outros idiomas

---

## 🔗 Links Úteis

### Documentação oficial das ferramentas:
| Ferramenta | Docs | GitHub |
|------------|------|--------|
| Checkov | [checkov.io](https://www.checkov.io/) | [github.com/bridgecrewio/checkov](https://github.com/bridgecrewio/checkov) |
| Gitleaks | [gitleaks.io](https://gitleaks.io/) | [github.com/gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) |
| TruffleHog | [trufflesecurity.com](https://trufflesecurity.com/trufflehog) | [github.com/trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog) |
| Trivy | [aquasecurity.github.io/trivy](https://aquasecurity.github.io/trivy/) | [github.com/aquasecurity/trivy](https://github.com/aquasecurity/trivy) |
| Snyk | [docs.snyk.io](https://docs.snyk.io/) | [github.com/snyk/cli](https://github.com/snyk/cli) |

### Recursos de aprendizado:
- 📚 [OWASP Top 10](https://owasp.org/www-project-top-ten/) — As 10 vulnerabilidades mais críticas
- 🎓 [Snyk Learn](https://learn.snyk.io/) — Cursos gratuitos de segurança
- 🔬 [CVE Database](https://cve.mitre.org/) — Base de dados de vulnerabilidades
- 🛡️ [NIST NVD](https://nvd.nist.gov/) — National Vulnerability Database
- 📖 [DevSecOps PlayBook](https://github.com/6mile/DevSecOps-Playbook) — Guia completo de DevSecOps

---

## ⚠️ Avisos Importantes

> **🚨 ATENÇÃO**: Este repositório contém código, configurações e segredos **PROPOSITALMENTE VULNERÁVEIS** para fins **exclusivamente educacionais**.

1. **NÃO** use os exemplos em ambientes de produção
2. **NÃO** use os segredos do `vulnerable-sample.env` — são todos falsos e fictícios
3. **NÃO** faça deploy do Terraform `main.tf` — criaria recursos AWS inseguros
4. Os findings das ferramentas são **esperados** — o objetivo é que encontrem problemas
5. Em projetos reais, configure `--exit-code 1` para bloquear deploys com CRITICAL
6. Rotacione credenciais imediatamente se encontrar segredos reais em commits

---

## 📝 Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE.md).

```
MIT License — Copyright (c) 2026 Toolbox Playground
```

---

<div align="center">

Feito com ❤️ pela equipe **[Toolbox Playground](https://github.com/toolbox-playground)**

⭐ Se este projeto te ajudou, considere dar uma estrela!

---

*Documentação verificada com [Context7](https://context7.com) • Março de 2026*

</div>
