# =============================================================================
# Exemplo Terraform corrigido para Lab 001 (baseline seguro)
# =============================================================================
# Este arquivo substitui os recursos intencionalmente vulneráveis por uma base
# mínima segura para demonstrar redução de findings no PR de hotfix.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  project_name = "caio-devsecops-lab001-fixed"
  environment  = "training"
}

output "project_name" {
  value       = local.project_name
  description = "Identificador do exemplo corrigido"
}
