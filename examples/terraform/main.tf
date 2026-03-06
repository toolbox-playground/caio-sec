# =============================================================================
# ⚠️  TERRAFORM PROPOSITALMENTE VULNERÁVEL - APENAS PARA FINS DIDÁTICOS  ⚠️
# =============================================================================
# Este arquivo Terraform contém misconfigurations INTENCIONAIS para demonstrar
# como o Checkov e o Trivy detectam problemas de segurança em IaC.
#
# NÃO USE EM PRODUÇÃO!
#
# Problemas de segurança presentes:
#   1. Bucket S3 com acesso público habilitado
#   2. Sem criptografia no bucket S3
#   3. Sem versionamento no bucket S3
#   4. Sem logging no bucket S3
#   5. Security Group com regras abertas (0.0.0.0/0)
#   6. RDS sem Multi-AZ e com backup desabilitado
#   7. IAM com permissões muito amplas (*)
# =============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # ⚠️ Sem backend remoto configurado - estado local não é seguro
  # Use S3 + DynamoDB para state remoto em produção
}

provider "aws" {
  region = "us-east-1"
  # ⚠️ Credenciais hardcoded - NUNCA faça isso!
  # Use IAM Roles, variáveis de ambiente ou AWS Vault
  # access_key = "AKIAIOSFODNN7EXAMPLE"
  # secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# =============================================================================
# ⚠️ RECURSO VULNERÁVEL #1: Bucket S3 Público
# Checkov: CKV_AWS_18, CKV_AWS_19, CKV_AWS_20, CKV_AWS_21, CKV_AWS_52
# =============================================================================
resource "aws_s3_bucket" "vulnerable_bucket" {
  bucket = "caio-devsecops-vulnerable-example"

  tags = {
    Name        = "Bucket Vulnerável - Apenas para Exemplo"
    Environment = "demo"
    Purpose     = "security-training"
  }
}

# ⚠️ VULNERABILIDADE: Acesso público habilitado
# Atacker pode ler/listar todos os objetos do bucket
resource "aws_s3_bucket_public_access_block" "vulnerable_bucket" {
  bucket = aws_s3_bucket.vulnerable_bucket.id

  block_public_acls       = false  # ⚠️ Deveria ser true
  block_public_policy     = false  # ⚠️ Deveria ser true
  ignore_public_acls      = false  # ⚠️ Deveria ser true
  restrict_public_buckets = false  # ⚠️ Deveria ser true
}

# ⚠️ VULNERABILIDADE: ACL pública (deprecada mas ainda existente)
resource "aws_s3_bucket_acl" "vulnerable_bucket" {
  bucket = aws_s3_bucket.vulnerable_bucket.id
  acl    = "public-read"  # ⚠️ Permite leitura pública de todos os arquivos
}

# ⚠️ VULNERABILIDADE: Sem criptografia (dados em repouso desprotegidos)
# Adicione em produção:
# resource "aws_s3_bucket_server_side_encryption_configuration" "example" { ... }

# ⚠️ VULNERABILIDADE: Sem versionamento (sem proteção contra deleção acidental)
# resource "aws_s3_bucket_versioning" "example" { ... }

# ⚠️ VULNERABILIDADE: Sem logging de acesso (sem auditoria)
# resource "aws_s3_bucket_logging" "example" { ... }

# =============================================================================
# ⚠️ RECURSO VULNERÁVEL #2: Security Group com Porta 22 e 3306 Abertas
# Checkov: CKV_AWS_25, CKV_AWS_24, CKV_AWS_277
# =============================================================================
resource "aws_security_group" "vulnerable_sg" {
  name        = "vulnerable-sg-example"
  description = "Security Group VULNERAVEL - Apenas para Exemplo"
  vpc_id      = "vpc-12345678"  # ⚠️ ID hardcoded (use data source)

  # ⚠️ VULNERABILIDADE: SSH aberto para todo o mundo
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ Nunca abra SSH para 0.0.0.0/0
    description = "SSH aberto para internet - VULNERAVEL"
  }

  # ⚠️ VULNERABILIDADE: MySQL aberto para todo o mundo
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ Banco de dados nunca deve ser público
    description = "MySQL aberto para internet - VULNERAVEL"
  }

  # ⚠️ VULNERABILIDADE: Todo tráfego de entrada permitido
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ Permite TUDO de qualquer origem
    description = "Todo trafego permitido - EXTREMAMENTE VULNERAVEL"
  }

  # ⚠️ VULNERABILIDADE: Todo tráfego de saída permitido sem restrições
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Geralmente aceitável mas pode ser restrito
    description = "Todo trafego de saida permitido"
  }

  tags = {
    Name = "vulnerable-sg-example"
  }
}

# =============================================================================
# ⚠️ RECURSO VULNERÁVEL #3: IAM Policy com Permissões Amplas
# Checkov: CKV_AWS_1, CKV_AWS_109, CKV_AWS_110, CKV_AWS_111
# =============================================================================
resource "aws_iam_policy" "vulnerable_policy" {
  name        = "vulnerable-policy-example"
  description = "Policy IAM VULNERAVEL - Apenas para Exemplo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["*"]         # ⚠️ Nunca use * em Actions
        Resource = ["*"]         # ⚠️ Nunca use * em Resources
        # ⚠️ Princípio do menor privilégio VIOLADO
        # Use apenas as permissões necessárias
      }
    ]
  })
}

# =============================================================================
# ⚠️ RECURSO VULNERÁVEL #4: RDS sem criptografia e sem Multi-AZ
# Checkov: CKV_AWS_16, CKV_AWS_17, CKV_AWS_129, CKV_AWS_157
# =============================================================================
resource "aws_db_instance" "vulnerable_rds" {
  identifier        = "vulnerable-rds-example"
  engine            = "mysql"
  engine_version    = "5.7"       # ⚠️ Versão antiga com CVEs conhecidos
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = "admin"
  password = "admin123"           # ⚠️ Senha fraca hardcoded

  # ⚠️ VULNERABILIDADE: Banco público (acessível pela internet)
  publicly_accessible = true

  # ⚠️ VULNERABILIDADE: Sem criptografia em repouso
  storage_encrypted = false

  # ⚠️ VULNERABILIDADE: Sem Multi-AZ (sem alta disponibilidade)
  multi_az = false

  # ⚠️ VULNERABILIDADE: Backup desabilitado (sem recuperação de desastres)
  backup_retention_period = 0

  # ⚠️ VULNERABILIDADE: Auto minor version upgrade desabilitado
  auto_minor_version_upgrade = false

  # ⚠️ VULNERABILIDADE: Sem deletion protection
  deletion_protection = false

  skip_final_snapshot = true

  tags = {
    Name = "vulnerable-rds-example"
  }
}

# =============================================================================
# OUTPUT DE EXEMPLO (com dados sensíveis - outra vulnerabilidade)
# =============================================================================

# ⚠️ VULNERABILIDADE: Não exporte dados sensíveis como outputs
output "bucket_name" {
  value       = aws_s3_bucket.vulnerable_bucket.id
  description = "Nome do bucket de exemplo"
}

# ⚠️ Nunca exponha senhas como outputs!
output "db_password" {
  value     = aws_db_instance.vulnerable_rds.password
  sensitive = false  # ⚠️ Deveria ser sensitive = true
}
