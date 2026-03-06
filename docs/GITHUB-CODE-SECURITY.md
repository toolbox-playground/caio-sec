# 🏫 GitHub Code Security — Dever de Casa

> **Fonte oficial**: [https://docs.github.com/pt/code-security](https://docs.github.com/pt/code-security)  
> Documentação verificada via [Context7](https://context7.com) • Março de 2026

---

## 📋 Índice

- [🎯 Objetivo](#-objetivo)
- [📖 O que é o GitHub Code Security?](#-o-que-é-o-github-code-security)
- [🔍 Secret Scanning](#-secret-scanning)
- [🧬 Code Scanning com CodeQL](#-code-scanning-com-codeql)
- [🤖 Dependabot](#-dependabot)
- [🔗 Dependency Review](#-dependency-review)
- [⛓️ Supply Chain Security](#-supply-chain-security)
- [📊 Security Overview](#-security-overview)
- [📝 Exercícios — Dever de Casa](#-exercícios--dever-de-casa)
- [✅ Checklist de Entrega](#-checklist-de-entrega)
- [🔗 Recursos](#-recursos)

---

## 🎯 Objetivo

Este documento cobre as ferramentas **nativas do GitHub** para segurança de código.
Enquanto os outros documentos desta pasta tratam de ferramentas externas (Gitleaks, Trivy, Checkov...),
o GitHub oferece sua própria suíte integrada acessível diretamente pela aba **Security** de cada repositório.

> 💡 **Dica**: As ferramentas do GitHub Code Security e as ferramentas desta pipeline se **complementam** — use as duas!

---

## 📖 O que é o GitHub Code Security?

O **GitHub Code Security** é o conjunto de funcionalidades nativas do GitHub para encontrar e corrigir vulnerabilidades. Ele inclui:

| Recurso | O que faz | Disponibilidade |
|---------|-----------|-----------------|
| 🔐 **Secret Scanning** | Detecta segredos e tokens expostos em commits | Público: grátis / Privado: Code Security |
| 🧬 **Code Scanning (CodeQL)** | Analisa o código em busca de vulnerabilidades | Público: grátis / Privado: Code Security |
| 🤖 **Dependabot Alerts** | Alerta sobre dependências com CVEs conhecidos | Grátis para todos |
| 🔄 **Dependabot Security Updates** | Cria PRs automáticos para corrigir deps vulneráveis | Grátis para todos |
| 🔗 **Dependency Review** | Revisa mudanças em dependências em PRs | Público: grátis / Privado: Code Security |
| ⛓️ **Supply Chain Security** | Monitoramento completo da cadeia de suprimentos | Code Security |
| 📊 **Security Overview** | Dashboard centralizado de alertas | Organizações |

### Como acessar

```
1. Abra seu repositório no GitHub
2. Clique na aba "Security" (ícone de escudo 🛡️)
3. Você verá o painel completo de alertas
```

---

## 🔍 Secret Scanning

O **Secret Scanning** verifica o histórico completo do Git em busca de tokens, chaves de API e outros segredos acidentalmente commitados.

### Como funciona

- Roda automaticamente em **repositórios públicos** (sem custo)
- Para repositórios privados, requer **GitHub Code Security**
- Verifica padrões fornecidos por **mais de 200 parceiros** (AWS, Stripe, GitHub, Google...)
- Gera **alertas na aba Security → Secret scanning alerts**

### Tipos de alertas

| Tipo | Descrição |
|------|-----------|
| **Secret scanning alerts for partners** | Ativado por padrão em repos públicos. Notifica o provedor automaticamente. |
| **Secret scanning alerts for users** | Exibe alertas também para você no repositório. Requer ativação. |

### Ativar no repositório

```
Settings → Code security → Secret scanning → Enable
```

### Push Protection

Bloqueia um push **antes** de chegar ao repositório se detectar um segredo:

```
Settings → Code security → Secret scanning → Push protection → Enable
```

```bash
# Exemplo: tentativa de push com segredo detectado
$ git push origin main
remote: error: GH013: Repository rule violations found for refs/heads/main.
remote:
remote: — Push cannot contain secrets —
remote:
remote: Secret found: AWS Access Key
remote: Location: examples/secrets/vulnerable-sample.env:3
remote:
remote: To skip this block, resolve the secret or use the bypass option.
```

### Padrão customizado (Custom Patterns)

Você pode criar padrões regex próprios para detectar segredos específicos da sua organização:

```
Settings → Code security → Secret scanning → Custom patterns → New pattern
```

Exemplo de padrão para tokens internos:
```
MINHA_EMPRESA_TOKEN_[A-Z0-9]{32}
```

### Filtros da API

```bash
# Listar alertas via GitHub CLI
gh api repos/{owner}/{repo}/secret-scanning/alerts

# Filtrar apenas alertas ativos com push protection bypassado
gh api repos/{owner}/{repo}/secret-scanning/alerts \
  --jq '.[] | select(.push_protection_bypassed == true)'
```

---

## 🧬 Code Scanning com CodeQL

O **Code Scanning** usa o **CodeQL** — a engine de análise de código desenvolvida pelo GitHub — para encontrar vulnerabilidades e erros de programação diretamente nos PRs e na branch principal.

### O que é CodeQL?

CodeQL trata o código como dados: transforma o código-fonte em um **banco de dados consultável** e executa queries para encontrar vulnerabilidades. Suporta:

| Linguagem | Detecção |
|-----------|----------|
| Python | SQL Injection, XSS, Command Injection, Path Traversal |
| JavaScript/TypeScript | XSS, Prototype Pollution, ReDoS |
| Java/Kotlin | XXE, SSRF, Deserialization |
| C/C++ | Buffer Overflow, Use-After-Free |
| Go, Ruby, Swift | Vários padrões OWASP |

### Setup — Default (recomendado para iniciantes)

Ativação com um clique:
```
Security tab → Code scanning → Set up → Default
```

O GitHub escolhe automaticamente:
- Linguagens detectadas no repositório
- Query suite a executar (`security-extended` por padrão)
- Eventos que disparam o scan (push + PR para main)

### Setup — Advanced (workflow customizável)

Gera um arquivo `.github/workflows/codeql.yml` editável:

```yaml
# .github/workflows/codeql.yml
name: "CodeQL Advanced"

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  schedule:
    - cron: '0 6 * * 1'   # Toda segunda-feira às 06:00 UTC

jobs:
  analyze:
    name: Analyze (${{ matrix.language }})
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      packages: read
      actions: read
      contents: read

    strategy:
      fail-fast: false
      matrix:
        language: ['python', 'javascript-typescript']
        # Adicione mais: 'java-kotlin', 'c-cpp', 'go', 'ruby', 'swift'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-extended   # ou: security-and-quality

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
```

### Query suites disponíveis

| Suite | Cobertura |
|-------|-----------|
| `default` | Alertas de alta confiança e baixo ruído |
| `security-extended` | Cobertura maior, inclui alertas de média confiança |
| `security-and-quality` | Segurança + problemas de qualidade de código |

### Interpretar os alertas

```
Security → Code scanning → Alert list
```

Cada alerta mostra:
- **Regra**: ex. `py/sql-injection`
- **Severidade**: Critical / High / Medium / Low
- **Localização**: arquivo e linha exata
- **Data flow**: caminho completo da vulnerabilidade (source → sink)
- **Autofix**: sugestão de correção gerada pelo Copilot (quando disponível)

---

## 🤖 Dependabot

O **Dependabot** monitora suas dependências e automaticamente cria PRs para corrigir vulnerabilidades.

### Dependabot Alerts

Detecta dependências com CVEs conhecidos no **GitHub Advisory Database**:

```
Security tab → Dependabot → Alerts
```

Filtros úteis:
```
dependabot.ecosystem: npm          # Apenas npm
dependabot.scope: runtime          # Apenas deps de produção
severity: critical                 # Apenas críticos
```

### Dependabot Security Updates

Cria PRs automáticos para atualizar dependências vulneráveis:

```
Settings → Code security → Dependabot → Security updates → Enable
```

O PR criado pelo Dependabot inclui:
- Diff da mudança de versão
- Release notes
- Compatibilidade com outros projetos (score de compatibilidade)
- Link direto para o CVE

### Dependabot Version Updates

Mantém **todas** as dependências atualizadas (não só as vulneráveis):

```yaml
# .github/dependabot.yml
version: 2
updates:
  # Atualiza dependências Python (pip)
  - package-ecosystem: "pip"
    directory: "/examples/python"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
      - "python"

  # Atualiza GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    labels:
      - "dependencies"
      - "github-actions"
```

### Ignorar alertas específicos

```yaml
# .github/dependabot.yml
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    ignore:
      - dependency-name: "requests"
        versions: ["2.28.*"]        # Ignora versão específica
      - dependency-name: "flask"
        update-types: ["version-update:semver-patch"]  # Ignora patches
```

---

## 🔗 Dependency Review

O **Dependency Review** analisa **mudanças em dependências nos PRs** e bloqueia a merge se introduzir vulnerabilidades.

### Como funciona

Ao abrir um PR que modifica arquivos de dependência (`requirements.txt`, `package.json`, `go.mod`...), o GitHub exibe um resumo das mudanças com destaque para CVEs introduzidos.

### Ativar via GitHub Action

```yaml
# .github/workflows/dependency-review.yml
name: Dependency Review

on:
  pull_request:
    branches: [ "main" ]

permissions:
  contents: read
  pull-requests: write

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          # Bloqueia PR se introduzir CVE com severidade >= high
          fail-on-severity: high
          # Permite licenças específicas
          allow-licenses: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause
          # Bloqueia licenças problemáticas
          deny-licenses: GPL-3.0, AGPL-3.0
          # Comenta no PR com o resumo
          comment-summary-in-pr: always
```

### Resultado no PR

```
✅ Dependency Review

Removed dependencies (0):
  None

Added dependencies (1):
  - requests 2.20.0 (HIGH CVE-2018-18074 - SSRF vulnerability)
                    ^^^^ Blocked: introduces a HIGH severity CVE

❌ This PR cannot be merged until the security issue is resolved.
```

---

## ⛓️ Supply Chain Security

A segurança da cadeia de suprimentos garante que não apenas o seu código, mas também o código/dependências de terceiros que você usa, são seguros.

### Dependency Graph

O **grafo de dependências** é a base de toda a supply chain security do GitHub:

```
Insights tab → Dependency graph
```

Mostra:
- Todos os pacotes diretos e transitivos
- Vulnerabilidades conhecidas por pacote
- Repositórios que dependem do seu projeto (dependents)

### SBOM — Software Bill of Materials

Gere um inventário completo de todas as dependências em formato padrão (SPDX):

```bash
# Via GitHub CLI
gh api repos/{owner}/{repo}/dependency-graph/sbom \
  --jq '.sbom' > sbom.json

# Via interface
Insights → Dependency graph → Export SBOM
```

### Melhores práticas da supply chain

Conforme documentado em [docs.github.com/pt/code-security/supply-chain-security](https://docs.github.com/pt/code-security/supply-chain-security):

1. **Inventário de dependências**: Mantenha o Dependency Graph ativo
2. **Monitoramento de vulnerabilidades**: Ative Dependabot Alerts
3. **Revisão em PRs**: Use Dependency Review Action
4. **Pinagem de versões**: Use versões fixas (não `>=`) em deps críticas
5. **Verificação de integridade**: Use hash SHA em `requirements.txt` com `pip-compile`

```bash
# Exemplo: requirements.txt com hashes
pip-compile --generate-hashes requirements.in
# Resultado: requests==2.31.0 --hash=sha256:58cd2187423839...
```

---

## 📊 Security Overview

O **Security Overview** é o painel centralizado de alertas de toda a organização.

### Acessar

```
Sua organização → Security tab
```

### Dashboards disponíveis

| Dashboard | O que mostra |
|-----------|--------------|
| **Overview** | Visão geral de todos os tipos de alerta |
| **CodeQL pull request alerts** | Impacto do CodeQL nos PRs e métricas de remediação |
| **Dependabot dashboard** | Vulnerabilidades críticas priorizadas por repositório |
| **Secret scanning** | Segredos expostos, push protection bypasses |

### Filtros avançados

```
# Exemplos de filtros na Security Overview
codeql.rule:py/sql-injection           # Apenas SQL injection via CodeQL
dependabot.ecosystem:pip               # Apenas deps Python
secret-scanning.provider:aws           # Apenas credenciais AWS
secret-scanning.bypassed:true          # Push protection foi ignorado
severity:critical                      # Apenas severidade crítica
```

---

## 📝 Exercícios — Dever de Casa

> 🎓 Complete os exercícios abaixo para consolidar o aprendizado.

---

### 📌 Exercício 1 — Ativar Secret Scanning (Básico)

**Objetivo**: Habilitar o secret scanning no seu fork do repositório e analisar os alertas.

**Passos**:
- [ ] Faça fork deste repositório para sua conta
- [ ] Acesse `Settings → Code security → Secret scanning`
- [ ] Ative **Secret scanning**
- [ ] Ative **Push protection**
- [ ] Acesse `Security → Secret scanning alerts`
- [ ] Liste todos os alertas encontrados no arquivo `examples/secrets/vulnerable-sample.env`

**Responda**:
1. Quantos segredos o GitHub detectou?
2. Quais providers identificou (AWS, GitHub, Stripe...)?
3. O que acontece se você tentar fazer um novo commit com um segredo?

---

### 📌 Exercício 2 — Configurar CodeQL (Intermediário)

**Objetivo**: Adicionar o workflow do CodeQL ao repositório e analisar os resultados.

**Passos**:
- [ ] Crie o arquivo `.github/workflows/codeql.yml` usando o template da seção [Setup — Advanced](#setup--advanced-workflow-customizável) acima
- [ ] Configure para analisar Python (o arquivo `examples/python/app.py` tem vulnerabilidades intencionais)
- [ ] Faça o push e aguarde a execução
- [ ] Acesse `Security → Code scanning alerts`
- [ ] Inspecione os alertas encontrados no `app.py`

**Responda**:
1. O CodeQL detectou SQL Injection no `app.py`?
2. Qual é a regra CodeQL que identificou o problema?
3. O alerta mostra o "data flow" (caminho da vulnerabilidade)? Descreva o source e o sink.
4. O Copilot Autofix sugeriu alguma correção?

---

### 📌 Exercício 3 — Dependabot (Básico)

**Objetivo**: Entender como o Dependabot monitora e corrige dependências vulneráveis.

**Passos**:
- [ ] Acesse `Security → Dependabot alerts` no seu fork
- [ ] Verifique os alertas no `examples/python/requirements.txt`
- [ ] Crie o arquivo `.github/dependabot.yml` com o conteúdo da seção [Dependabot Version Updates](#dependabot-version-updates) acima
- [ ] Aguarde ou dispare manualmente: `Insights → Dependency graph → Dependabot → Last checked`
- [ ] Verifique se PRs foram criados automaticamente

**Responda**:
1. Quais pacotes em `requirements.txt` têm CVEs conhecidos?
2. Qual é o CVE mais grave encontrado? Qual o CVSS score?
3. O Dependabot criou algum PR automático? O que ele propõe mudar?

---

### 📌 Exercício 4 — Dependency Review em PR (Intermediário)

**Objetivo**: Usar a Dependency Review Action para bloquear PRs que introduzem vulnerabilidades.

**Passos**:
- [ ] Crie o arquivo `.github/workflows/dependency-review.yml` usando o template acima
- [ ] Crie uma branch nova: `git checkout -b test/vulnerable-dep`
- [ ] Edite `examples/python/requirements.txt` e adicione uma versão antiga com CVE:
  ```
  flask==0.12.2
  ```
- [ ] Faça push e abra um PR para `main`
- [ ] Observe o comentário automático no PR

**Responda**:
1. A action bloqueou o PR?
2. Qual CVE foi detectado no Flask 0.12.2?
3. O que é necessário fazer para a review aprovar o PR?

---

### 📌 Exercício 5 — Security Overview e SBOM (Avançado)

**Objetivo**: Explorar o painel de segurança e gerar um SBOM do projeto.

**Passos**:
- [ ] Acesse `Insights → Dependency graph` no seu fork
- [ ] Exporte o SBOM (botão "Export SBOM")
- [ ] Abra o arquivo JSON e identifiquem os campos `SPDXID`, `name`, `versionInfo`
- [ ] (Opcional) Use o GitHub CLI para consultar a API:
  ```bash
  gh api repos/{SEU_USUARIO}/caio-sec/dependency-graph/sbom \
    --jq '.sbom.packages[] | {name: .name, version: .versionInfo}'
  ```

**Responda**:
1. Quantos pacotes (diretos + transitivos) o SBOM listou?
2. Qual é o formato padrão do SBOM exportado pelo GitHub (SPDX ou CycloneDX)?
3. Como o SBOM pode ser usado em auditorias de compliance?

---

### 📌 Exercício 6 — Comparando ferramentas (Avançado)

**Objetivo**: Comparar as ferramentas desta pipeline com as ferramentas nativas do GitHub.

**Preencha a tabela abaixo** com base nos resultados dos outros exercícios e dos docs desta pasta:

| Capacidade | Gitleaks | TruffleHog | GitHub Secret Scanning |
|------------|----------|------------|------------------------|
| Detecta segredos no histórico | ✅ | ✅ | ✅ |
| Verifica se segredo está ativo | ❌ | ✅ | ✅ (parcialmente) |
| Bloqueia no pre-commit | ✅ | ❌ | ✅ (push protection) |
| Padrões customizados | ✅ | ✅ | ✅ |
| Custo | Grátis | Grátis | Grátis (público) |

| Capacidade | Checkov | Snyk IaC | CodeQL |
|------------|---------|----------|--------|
| Analisa Terraform | ✅ | ✅ | ❌ |
| Analisa código Python | ❌ | ✅ | ✅ |
| Integração nativa GitHub | Via Action | Via Action | ✅ nativo |
| Data flow analysis | ❌ | Parcial | ✅ completo |

**Responda**:
1. Para que tipo de projeto você usaria CodeQL vs Checkov? Por quê?
2. Existe alguma sobreposição entre Dependabot e Trivy? Como você escolheria qual usar?
3. Qual ferramenta você adicionaria à pipeline `unified-security-pipeline.yaml` e por quê?

---

## ✅ Checklist de Entrega

Antes de considerar o dever de casa concluído, verifique:

- [ ] Fork do repositório criado com Secret Scanning ativado
- [ ] Arquivo `.github/workflows/codeql.yml` criado e executado com sucesso
- [ ] Arquivo `.github/dependabot.yml` criado
- [ ] Arquivo `.github/workflows/dependency-review.yml` criado
- [ ] Exercícios 1 a 4 respondidos (mínimo obrigatório)
- [ ] Todos os alertas da aba Security foram revisados e compreendidos
- [ ] (Bonus) Exercícios 5 e 6 respondidos

---

## 🔗 Recursos

### Documentação oficial (português)
- 📖 [GitHub Code Security — Visão Geral](https://docs.github.com/pt/code-security)
- 🔐 [Secret Scanning](https://docs.github.com/pt/code-security/secret-scanning)
- 🧬 [Code Scanning com CodeQL](https://docs.github.com/pt/code-security/code-scanning)
- 🤖 [Dependabot](https://docs.github.com/pt/code-security/dependabot)
- 🔗 [Dependency Review](https://docs.github.com/pt/code-security/supply-chain-security/understanding-your-software-supply-chain/about-dependency-review)
- ⛓️ [Supply Chain Security](https://docs.github.com/pt/code-security/supply-chain-security)
- 📊 [Security Overview](https://docs.github.com/pt/code-security/security-overview)

### GitHub Actions usadas nos exercícios
- [`github/codeql-action`](https://github.com/github/codeql-action) — CodeQL Analysis
- [`actions/dependency-review-action`](https://github.com/actions/dependency-review-action) — Dependency Review

### Relacionado neste repositório
| Ferramenta | Doc | Complementa |
|------------|-----|-------------|
| [GITLEAKS.md](GITLEAKS.md) | Detecção local de segredos | GitHub Secret Scanning |
| [TRUFFLEHOG.md](TRUFFLEHOG.md) | Verificação ativa de segredos | GitHub Secret Scanning |
| [TRIVY.md](TRIVY.md) | Scanner de vulnerabilidades | Dependabot Alerts |
| [CHECKOV.md](CHECKOV.md) | Segurança de IaC | Code Scanning (parcial) |
| [SNYK.md](SNYK.md) | SAST + deps | CodeQL + Dependabot |

---

*Documentação verificada com [Context7](https://context7.com) • [docs.github.com/pt/code-security](https://docs.github.com/pt/code-security) • Março de 2026*
