# 🛡️ Trivy - Guia Completo

> Scanner de vulnerabilidades tudo-em-um para containers, código e infraestrutura

---

## 📋 Índice

- [O que é Trivy?](#o-que-é-trivy)
- [Tipos de scan](#tipos-de-scan)
- [Como instalar](#como-instalar)
- [Comandos principais](#comandos-principais)
- [Entendendo severidades](#entendendo-severidades)
- [Scan de containers](#scan-de-containers)
- [Scan de filesystem](#scan-de-filesystem)
- [Scan de IaC](#scan-de-iac)
- [Exemplos práticos](#exemplos-práticos)
- [Links úteis](#links-úteis)

---

## 🔍 O que é Trivy?

**Trivy** é um scanner de segurança open-source desenvolvido pela **Aqua Security**. É considerado o mais **completo e fácil de usar** da categoria, com suporte a múltiplos tipos de scan em um único binário.

### Por que Trivy?
- 🚀 **Zero configuração**: Funciona imediatamente, sem setup complexo
- 🌐 **Cobertura ampla**: CVEs de múltiplos bancos de dados (NVD, GitHub Advisory, etc.)
- 🐳 **Nativo para containers**: Criado pensando em DevOps/DevSecOps
- 📦 **Múltiplos alvos**: Imagens Docker, filesystems, repositórios Git, código, IaC
- 🔄 **Cache de banco de dados**: Não precisa baixar CVEs a cada execução
- 📊 **Formatos flexíveis**: Table, JSON, SARIF, Template customizado

---

## 🎯 Tipos de scan

| Tipo | Comando | O que analisa |
|------|---------|---------------|
| **Image** | `trivy image` | Imagens Docker/OCI |
| **Filesystem** | `trivy filesystem` | Sistema de arquivos, dependências |
| **Repository** | `trivy repo` | Repositório Git remoto |
| **Config** | `trivy config` | IaC (Terraform, Dockerfile, K8s) |
| **SBOM** | `trivy sbom` | Software Bill of Materials |
| **Kubernetes** | `trivy k8s` | Cluster Kubernetes ativo |
| **AWS** | `trivy aws` | Conta AWS (recursos reais) |
| **VM Image** | `trivy vm` | Imagens de VM |

### Categorias de findings:

| Categoria | Descrição |
|-----------|-----------|
| **vuln** | Vulnerabilidades CVE em pacotes |
| **secret** | Segredos e credenciais |
| **misconfig** | Misconfigurations em IaC e containers |
| **license** | Problemas de licença em dependências |

---

## 📦 Como instalar

### Método 1: Script de instalação (Recomendado)
```bash
# Instala versão mais recente automaticamente
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sudo sh -s -- -b /usr/local/bin

# Versão específica
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sudo sh -s -- -b /usr/local/bin v0.58.0

# Verifica
trivy --version
```

### Método 2: Homebrew (macOS)
```bash
brew install aquasecurity/trivy/trivy
```

### Método 3: Docker (sem instalar)
```bash
# Scan de imagem Docker
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest \
  image nginx:latest

# Scan de filesystem local
docker run --rm \
  -v "$(pwd):/workdir" \
  -w /workdir \
  aquasec/trivy:latest \
  filesystem .
```

### Método 4: apt (Ubuntu/Debian)
```bash
# Adiciona repositório oficial
sudo apt-get install -y wget apt-transport-https gnupg lsb-release

# Chave GPG
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# Repositório
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list

# Instala
sudo apt-get update
sudo apt-get install -y trivy

# Verifica
trivy --version
```

### Método 5: RPM (CentOS/RHEL/Fedora)
```bash
sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.58.0/trivy_0.58.0_Linux-64bit.rpm
```

---

## 🛠️ Comandos principais

### Estrutura básica
```
trivy <alvo> [flags] <referência>
```

### Flags globais essenciais:

| Flag | Descrição |
|------|-----------|
| `--severity` | Filtra por gravidade: CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN |
| `--format` | Formato: table, json, sarif, template, cyclonedx, spdx |
| `--output` | Arquivo de saída |
| `--exit-code 1` | Falha com código 1 se encontrar vulnerabilidades |
| `--ignore-unfixed` | Ignora vulnerabilidades sem fix disponível |
| `--quiet` | Modo silencioso |
| `--no-progress` | Remove barra de progresso |
| `--cache-dir` | Diretório de cache do banco de CVEs |

---

## 🔴 Entendendo severidades

| Severidade | Cor | CVSS Score | Ação Recomendada |
|------------|-----|------------|-----------------|
| **CRITICAL** | 🔴 Vermelho | 9.0 - 10.0 | Corrigir IMEDIATAMENTE |
| **HIGH** | 🟠 Laranja | 7.0 - 8.9 | Corrigir no próximo sprint |
| **MEDIUM** | 🟡 Amarelo | 4.0 - 6.9 | Criar ticket e agendar |
| **LOW** | 🔵 Azul | 0.1 - 3.9 | Monitorar e corrigir quando possível |
| **UNKNOWN** | ⚪ Cinza | N/A | Investigar manualmente |

### CVSS (Common Vulnerability Scoring System):
```
Score 10.0 = CVE crítico (ex: exploração remota sem autenticação)
Score 0.0  = Risco mínimo

Exemplo: CVE-2021-44228 (Log4Shell) = CVSS 10.0 (CRITICAL)
```

---

## 🐳 Scan de containers

```bash
# Scan de imagem local
trivy image nginx:latest

# Scan de imagem com severidade filtrada
trivy image --severity CRITICAL,HIGH nginx:latest

# Scan de imagem local (não busca no registry)
trivy image --input /path/to/image.tar

# Apenas vulnerabilidades (sem misconfig, secrets)
trivy image --scanners vuln nginx:latest

# Todos os tipos de scan
trivy image \
  --scanners vuln,misconfig,secret \
  --severity CRITICAL,HIGH \
  nginx:latest

# Output JSON com todos os detalhes
trivy image --format json --output report.json nginx:latest

# Falha se encontrar CRITICAL
trivy image --exit-code 1 --severity CRITICAL nginx:latest

# Scan da imagem de exemplo vulnerável do projeto
trivy image \
  --severity CRITICAL,HIGH,MEDIUM \
  --format table \
  --no-progress \
  caio-devsecops-example:latest
```

### Entendendo o output de imagem:
```
caio-devsecops-example:latest (debian 11.8)
==============================================
Total: 35 (CRITICAL: 8, HIGH: 15, MEDIUM: 12)

┌──────────────────────┬────────────────┬──────────┬────────┐
│       Library        │  Vulnerability │ Severity │  Fix   │
├──────────────────────┼────────────────┼──────────┼────────┤
│ libssl1.1            │ CVE-2023-xxxx  │ CRITICAL │ 1.1.1w │
│ python3.8            │ CVE-2023-yyyy  │ HIGH     │ 3.8.18 │
└──────────────────────┴────────────────┴──────────┴────────┘
```

---

## 📁 Scan de filesystem

```bash
# Scan de dependências Python no diretório
trivy filesystem examples/python/

# Scan apenas de vulnerabilidades em dependências
trivy filesystem \
  --scanners vuln \
  --severity CRITICAL,HIGH \
  examples/python/

# Scan completo: vuln + secrets + misconfig
trivy filesystem \
  --scanners vuln,misconfig,secret \
  .

# Scan de arquivo específico (requirements.txt, package.json, etc.)
trivy filesystem \
  --scanners vuln \
  examples/python/requirements.txt
```

---

## 🏗️ Scan de IaC (Config)

```bash
# Scan de configurações do diretório atual
trivy config .

# Scan de Terraform
trivy config examples/terraform/

# Scan de Dockerfiles
trivy config examples/python/Dockerfile

# Scan de múltiplos tipos com severidade
trivy config \
  --severity CRITICAL,HIGH,MEDIUM \
  --format table \
  .

# Scan com output JSON
trivy config \
  --format json \
  --output config-report.json \
  .
```

### Checks de IaC disponíveis:
| Check ID | Descrição |
|----------|-----------|
| `AVD-AWS-0086` | Bucket S3 sem criptografia |
| `AVD-AWS-0020` | Security Group com port 22 aberto |
| `AVD-DFT-0001` | Dockerfile rodando como root |
| `AVD-KSV-0001` | Container sem limites de CPU/memória |

---

## 📖 Exemplos práticos

### Exemplo 1: Pipeline completa de segurança
```bash
#!/bin/bash
# security-scan.sh — Scan completo com Trivy

IMAGE_NAME="minha-app:latest"
REPORT_DIR="./trivy-reports"
mkdir -p $REPORT_DIR

echo "🔨 Building imagem..."
docker build -t $IMAGE_NAME .

echo "🔍 Scan da imagem Docker..."
trivy image \
  --severity CRITICAL,HIGH \
  --format json \
  --output $REPORT_DIR/image-report.json \
  --no-progress \
  $IMAGE_NAME

echo "📁 Scan das dependências..."
trivy filesystem \
  --scanners vuln \
  --severity CRITICAL,HIGH \
  --format json \
  --output $REPORT_DIR/deps-report.json \
  --no-progress \
  .

echo "🏗️  Scan de IaC..."
trivy config \
  --severity CRITICAL,HIGH,MEDIUM \
  --format json \
  --output $REPORT_DIR/iac-report.json \
  --no-progress \
  .

echo "✅ Relatórios salvos em $REPORT_DIR/"
```

### Exemplo 2: Integração com GitHub Actions
```yaml
- name: Scan com Trivy
  run: |
    # Scan de imagem
    trivy image \
      --format sarif \
      --output trivy-image.sarif \
      --no-progress \
      minha-app:latest || true

    # Scan de IaC
    trivy config \
      --format sarif \
      --output trivy-config.sarif \
      --no-progress \
      . || true

- name: Upload para GitHub Security
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: trivy-image.sarif
```

### Exemplo 3: Usando `.trivyignore` para suprimir falsos positivos
```bash
# .trivyignore — Ignora CVEs específicos com justificativa
# Formato: CVE-ID # comentário com justificativa

CVE-2022-1234 # Mitigado por firewall de rede, risco aceitável
CVE-2023-5678 # Sem fix disponível, monitorando
```

```bash
# Usando o arquivo de ignore
trivy image --ignorefile .trivyignore nginx:latest
```

---

## 🔗 Links úteis

| Recurso | URL |
|---------|-----|
| Repositório GitHub | [https://github.com/aquasecurity/trivy](https://github.com/aquasecurity/trivy) |
| Documentação oficial | [https://aquasecurity.github.io/trivy/](https://aquasecurity.github.io/trivy/) |
| AVD (Advisory Database) | [https://avd.aquasec.com/](https://avd.aquasec.com/) |
| Trivy Checks | [https://avd.aquasec.com/misconfig/](https://avd.aquasec.com/misconfig/) |
| Releases | [https://github.com/aquasecurity/trivy/releases](https://github.com/aquasecurity/trivy/releases) |
| Aqua Security Blog | [https://blog.aquasec.com/](https://blog.aquasec.com/) |

---

> **Dica pro**: Use `trivy image --ignore-unfixed` para focar apenas em vulnerabilidades que JÁ TÊM patch disponível — isso torna os relatórios muito mais acionáveis!
