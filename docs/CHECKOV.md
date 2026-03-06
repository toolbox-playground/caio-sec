# 🏗️ Checkov - Guia Completo

> Análise estática de segurança para Infraestrutura como Código (IaC)

---

## 📋 Índice

- [O que é Checkov?](#o-que-é-checkov)
- [Como funciona?](#como-funciona)
- [Como instalar](#como-instalar)
- [Comandos principais](#comandos-principais)
- [Exemplos de uso](#exemplos-de-uso)
- [Como interpretar resultados](#como-interpretar-resultados)
- [Configuração avançada](#configuração-avançada)
- [Integração com CI/CD](#integração-com-cicd)
- [Links úteis](#links-úteis)

---

## 🔍 O que é Checkov?

**Checkov** é uma ferramenta de análise estática de código open-source desenvolvida pela **Bridgecrew (adquirida pela Palo Alto Networks)**. Ela verifica arquivos de Infraestrutura como Código (IaC) em busca de misconfigurations de segurança e compliance.

### Suporte a frameworks:
| Framework | Extensão |
|-----------|----------|
| Terraform | `.tf` |
| Terraform Plan | `.json` |
| CloudFormation | `.yaml`, `.json` |
| Kubernetes | `.yaml` |
| Helm | Charts |
| Dockerfile | `Dockerfile` |
| GitHub Actions | `.github/workflows/*.yaml` |
| ARM Templates | `.json` |
| Bicep | `.bicep` |
| Ansible | `.yaml` |
| Azure Pipelines | `.yaml` |

### Certificações e Compliance:
- **CIS Benchmarks** (AWS, Azure, GCP)
- **PCI-DSS**
- **HIPAA**
- **SOC2**
- **NIST 800-53**

---

## ⚙️ Como funciona?

O Checkov analisa o código IaC estaticamente (sem executar/provisionar nada) e verifica contra um conjunto de **policies** pré-definidas ou customizadas.

```
Código Terraform/Dockerfile
          ↓
    Parsing do arquivo
          ↓
  Geração de grafo de recursos
          ↓
  Aplicação de políticas (checks)
          ↓
    Relatório PASS/FAIL
```

### Tipos de checks:
- **Graph checks**: Analisa relacionamentos entre recursos
- **Attribute checks**: Verifica atributos individuais
- **Wildcard checks**: Verifica padrões em múltiplos recursos

---

## 📦 Como instalar

### 🐧 Linux — pip3 (Usado na pipeline)
```bash
pip3 install checkov
checkov --version
pip3 install -U checkov  # Atualizar
```

### 🐧 Linux — Ambiente virtual / venv (Debian 12+)
> No Debian 12+, o pip do sistema é gerenciado e requer venv para instalar pacotes globalmente.

```bash
# Cria e ativa o ambiente virtual
python3 -m venv /opt/venv/checkov
source /opt/venv/checkov/bin/activate

# Instala dentro do venv
pip install checkov

# Opcional: criar symlink para acesso global
sudo ln -s /opt/venv/checkov/bin/checkov /usr/local/bin/checkov

# Verifica
checkov --version
```

### 🪟 Windows — PowerShell
```powershell
# pip3 funciona nativamente no Windows com Python instalado
pip3 install checkov
checkov --version

# Atualizar
pip3 install -U checkov
```

### 🍎 macOS — Homebrew
```bash
brew install checkov
```

### 🐳 Docker (todas as plataformas)
```bash
# Linux/macOS — scan de diretório
docker run --rm \
  -v "$(pwd):/tf" \
  bridgecrew/checkov \
  --directory /tf

# Com relatório SARIF
docker run --rm \
  -v "$(pwd):/tf" \
  bridgecrew/checkov \
  --directory /tf \
  --output sarif \
  --output-file-path /tf/results.sarif
```

```powershell
# Windows PowerShell
docker run --rm `
  -v "${PWD}:/tf" `
  bridgecrew/checkov `
  --directory /tf
```

---

## 🛠️ Comandos principais

### Estrutura básica
```
checkov [opções] --directory <caminho> | --file <arquivo>
```

### Comandos essenciais

```bash
# Scan de um diretório Terraform
checkov --directory ./terraform

# Scan de um arquivo específico
checkov --file main.tf

# Scan de Dockerfile
checkov --file Dockerfile --framework dockerfile

# Scan de múltiplos frameworks
checkov --directory . --framework terraform,dockerfile,github_actions

# Listar todos os checks disponíveis
checkov --list

# Filtrar por severidade
checkov --directory . --check CRITICAL,HIGH
```

### Opções de output

```bash
# Output em tabela (padrão)
checkov --directory . --output cli

# Output em JSON
checkov --directory . --output json

# Output em SARIF (para GitHub Security)
checkov --directory . --output sarif --output-file-path .

# Múltiplos formatos ao mesmo tempo
checkov --directory . --output cli --output json --output sarif

# Salvar em arquivo específico
checkov --directory . --output json > results.json
```

### Opções de controle

```bash
# Não falhar mesmo com findings (útil para CI)
checkov --directory . --soft-fail

# Pular checks específicos
checkov --directory . --skip-check CKV_AWS_20,CKV_AWS_18

# Executar apenas checks específicos
checkov --directory . --check CKV_AWS_1,CKV_AWS_2

# Pular diretórios/arquivos
checkov --directory . --skip-path node_modules --skip-path .terraform
```

---

## 📖 Exemplos de uso

### Exemplo 1: Scan básico de Terraform
```bash
checkov --directory examples/terraform \
  --output cli \
  --compact
```

**Saída esperada para nosso exemplo vulnerável:**
```
Passed checks: 2, Failed checks: 12, Skipped checks: 0

Check: CKV_AWS_20: "Ensure the S3 bucket has access control list (ACL) applied"
  FAILED for resource: aws_s3_bucket.vulnerable_bucket
  File: /examples/terraform/main.tf:15-25

Check: CKV_AWS_19: "Ensure all data stored in the S3 bucket is encrypted using SSE"
  FAILED for resource: aws_s3_bucket.vulnerable_bucket
  ...
```

### Exemplo 2: Scan de Dockerfile
```bash
checkov --file examples/python/Dockerfile \
  --framework dockerfile
```

### Exemplo 3: Scan completo com múltiplos outputs
```bash
checkov \
  --directory . \
  --output cli \
  --output sarif \
  --output-file-path ./reports \
  --soft-fail \
  --compact
```

### Exemplo 4: Integração com Terraform Plan
```bash
# Gerar plano Terraform
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json

# Analisar o plan com Checkov
checkov --file tfplan.json --framework terraform_plan
```

---

## 📊 Como interpretar resultados

### Status dos checks:
| Status | Significado |
|--------|-------------|
| ✅ **PASSED** | Recurso está em conformidade com a política |
| ❌ **FAILED** | Recurso viola a política de segurança |
| ⚠️ **SKIPPED** | Check foi explicitamente ignorado |

### Estrutura de um finding:
```
Check: CKV_AWS_20: "Ensure the S3 bucket has access control list (ACL) applied"
	FAILED for resource: aws_s3_bucket.example
	File: /main.tf:5-20
	Guide: https://docs.bridgecrew.io/docs/s3_14-data-encrypted-at-rest

		5 | resource "aws_s3_bucket" "example" {
		6 |   bucket = "my-bucket"
		...
```

### Identificadores de checks:
- `CKV_AWS_*` - AWS
- `CKV_AZURE_*` - Azure
- `CKV_GCP_*` - Google Cloud
- `CKV_K8S_*` - Kubernetes
- `CKV_DOCKER_*` - Dockerfile
- `CKV2_*` - Checks de segunda geração (graph-based)

---

## ⚙️ Configuração avançada

### Arquivo de configuração (`.checkov.yaml`)
```yaml
# .checkov.yaml — Configuração do Checkov para o projeto
directory:
  - "."
skip-check:
  - CKV_AWS_20   # Exemplo: ignorar check de ACL S3
  - CKV_AWS_18   # Exemplo: ignorar logging S3
framework:
  - terraform
  - dockerfile
output:
  - cli
  - sarif
output-file-path: reports/
soft-fail: true
compact: true
```

### Criando checks customizados (Python)
```python
from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class ExampleCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure my custom policy"
        id = "CKV_CUSTOM_1"
        supported_resources = ['aws_s3_bucket']
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, 
                         categories=categories,
                         supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        # Sua lógica aqui
        if conf.get("my_attribute"):
            return CheckResult.PASSED
        return CheckResult.FAILED

scanner = ExampleCheck()
```

### Suprimindo falsos positivos inline
```hcl
# No arquivo Terraform, use comentários para suprimir
resource "aws_s3_bucket" "example" {
  #checkov:skip=CKV_AWS_20:Bucket público intencional para website estático
  bucket = "my-public-website"
}
```

---

## 🔗 Integração com CI/CD

### GitHub Actions (manual, sem action pronta)
```yaml
- name: Instalar Checkov
  run: pip3 install checkov

- name: Executar Checkov
  run: |
    checkov \
      --directory . \
      --output sarif \
      --output-file-path . \
      --soft-fail
```

### GitLab CI
```yaml
checkov:
  image: python:3.11-slim
  script:
    - pip3 install checkov
    - checkov --directory . --output sarif --soft-fail
  artifacts:
    reports:
      sast: results_sarif.sarif
```

---

## 🔗 Links úteis

| Recurso | URL |
|---------|-----|
| Documentação oficial | [https://www.checkov.io/](https://www.checkov.io/) |
| Repositório GitHub | [https://github.com/bridgecrewio/checkov](https://github.com/bridgecrewio/checkov) |
| Registry de Checks | [https://www.checkov.io/5.Policy%20Index/terraform.html](https://www.checkov.io/5.Policy%20Index/terraform.html) |
| Bridgecrew Platform | [https://bridgecrew.io/](https://bridgecrew.io/) |
| PyPI | [https://pypi.org/project/checkov/](https://pypi.org/project/checkov/) |

---

> **Dica pro**: Use `checkov --output sarif` para integrar com o GitHub Security tab e visualizar os findings diretamente no código!
