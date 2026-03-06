## 0.2.0 (2026-03-06)

### Feat

- Remover verificação de token do SonarQube na condição de execução do job
- Adicionar análise SAST com SonarQube à pipeline unificada e atualizar documentação do Gitleaks e TruffleHog
- Substituir opção --no-progress por --quiet nas execuções do Trivy para melhorar a legibilidade dos logs
- Substituir netcat por netcat-openbsd no Dockerfile para reduzir vulnerabilidades
- Atualizar parâmetros do TruffleHog para resultados de verificação mais abrangentes
- Adicionar opção --no-update ao TruffleHog para evitar atualizações automáticas durante a análise
- Atualizar comandos do Gitleaks para detecção de segredos no histórico e em arquivos

## 0.1.0 (2026-03-05)

### Feat

- Atualizar documentação e scripts de instalação para Checkov, Gitleaks e Trivy; ajustar comandos e melhorar clareza
- Add comprehensive TruffleHog documentation and examples; introduce intentionally vulnerable Dockerfile, Python app, and Terraform configuration for educational purposes
