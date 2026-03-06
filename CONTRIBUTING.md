# 🤝 Guia de Contribuição

Obrigado pelo interesse em contribuir com o **CaioDevSecOps**! Este é um projeto educacional e toda contribuição é bem-vinda.

---

## 📋 Índice

- [Código de Conduta](#-código-de-conduta)
- [Como Reportar Bugs](#-como-reportar-bugs)
- [Como Sugerir Features](#-como-sugerir-features)
- [Configuração do Ambiente](#-configuração-do-ambiente)
- [Guidelines de Código](#️-guidelines-de-código)
- [Processo de Pull Request](#-processo-de-pull-request)
- [Como Adicionar Novas Ferramentas](#-como-adicionar-novas-ferramentas)
- [Como Melhorar a Documentação](#-como-melhorar-a-documentação)

---

## 📜 Código de Conduta

Este projeto adota o **Contributor Covenant Code of Conduct**. Ao participar, você concorda em seguir estes princípios:

- ✅ Seja respeitoso e inclusivo com todos os participantes
- ✅ Aceite críticas construtivas com abertura
- ✅ Foque no que é melhor para a comunidade
- ✅ Demonstre empatia com outros membros
- ❌ Não use linguagem ou imagens ofensivas
- ❌ Não faça ataques pessoais ou políticos
- ❌ Não publique informações privadas de outras pessoas

Para reportar violações: abra uma issue com o label `conduct`.

---

## 🐛 Como Reportar Bugs

Encontrou um problema? Ótimo! Bugs reportados nos ajudam a melhorar.

### Antes de reportar:
1. Verifique se já não existe uma [issue aberta](https://github.com/toolbox-playground/CaioDevSecOps/issues) com o mesmo problema
2. Teste na versão mais recente do repositório
3. Veja a seção [Troubleshooting](README.md#-troubleshooting) no README

### Como abrir uma issue de bug:
```
Título: [BUG] Descrição curta do problema

Template:
## Descrição
Descreva o bug claramente.

## Passos para reproduzir
1. Clone o repositório
2. Execute o comando X
3. ...

## Comportamento esperado
O que deveria acontecer.

## Comportamento atual
O que está acontecendo.

## Ambiente
- OS: Ubuntu 22.04 / macOS 14 / Windows 11
- Python: 3.11
- Docker: 24.0
- Checkov: 3.2.0 (se relevante)

## Logs / Screenshots
Cole aqui os logs de erro relevantes.
```

---

## 💡 Como Sugerir Features

Tem uma ideia para melhorar o projeto? Adoramos ouvir!

### Como abrir uma issue de feature request:
```
Título: [FEATURE] Descrição da funcionalidade

Template:
## Descrição da Feature
Descreva a funcionalidade que você gostaria de ver.

## Problema que resolve
Qual problema ou limitação atual isso resolve?

## Solução proposta
Como você imagina que a feature funcionaria?

## Alternativas consideradas
Você considerou outras soluções? Por que esta é melhor?

## Contexto adicional
Qualquer informação adicional que possa ajudar.
```

---

## ⚙️ Configuração do Ambiente

### Pré-requisitos:
- Git
- Python 3.11+
- Docker (para testar exemplos)
- Node.js 20+ (para Snyk)

### Setup:
```bash
# 1. Fork o repositório (botão "Fork" no GitHub)

# 2. Clone seu fork
git clone https://github.com/SEU-USUARIO/CaioDevSecOps.git
cd CaioDevSecOps

# 3. Adicione o repositório original como upstream
git remote add upstream https://github.com/toolbox-playground/CaioDevSecOps.git

# 4. (Opcional) Instale as ferramentas localmente para testar
pip install checkov

# Gitleaks
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.4/gitleaks_8.18.4_linux_x64.tar.gz -O /tmp/gl.tar.gz
tar -xzf /tmp/gl.tar.gz -C /tmp/ && sudo mv /tmp/gitleaks /usr/local/bin/

# TruffleHog
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sudo sh -s -- -b /usr/local/bin

# Trivy (Ubuntu/Debian)
sudo apt-get install trivy

# Snyk
npm install -g snyk
```

---

## 🖊️ Guidelines de Código

### Geral:
- Código e comentários em **português brasileiro**
- Espaçamento de 2 ou 4 espaços (conforme a linguagem)
- Sem linhas em branco no final dos arquivos
- Máximo de 100 caracteres por linha

### YAML (workflows):
```yaml
# ✅ Bom — com comentários explicativos
- name: 📦 Instalar Checkov via pip
  run: |
    echo "::group::Instalando Checkov"
    pip install checkov         # Instalação manual sem actions prontas
    checkov --version           # Confirma instalação
    echo "::endgroup::"

# ❌ Evite — sem comentários, nome genérico
- name: step1
  run: pip install checkov
```

### Markdown:
- Use emojis para melhor visualização
- Tabelas para comparações e listas de opções
- Code blocks com linguagem especificada
- Cabeçalhos hierarchicos (H1 → H2 → H3)

### Python (exemplos vulneráveis):
- Marque **claramente** cada vulnerabilidade com `# ⚠️ VULNERABILIDADE #N: Descrição`
- Inclua comentários sobre qual ferramenta detecta o problema
- Adicione o aviso de disclaimer no topo do arquivo

### Terraform (exemplos):
- Inclua o ID do check Checkov relevante no comentário
- Explique o risco de segurança de cada misconfiguration

---

## 🔀 Processo de Pull Request

### Passos:

**1. Sincronize com upstream**
```bash
git fetch upstream
git checkout main
git merge upstream/main
```

**2. Crie uma branch descritiva**
```bash
# Para nova feature
git checkout -b feat/add-semgrep-tool

# Para correção de bug
git checkout -b fix/checkov-scan-path

# Para documentação
git checkout -b docs/improve-trivy-guide
```

**3. Faça suas alterações**
```bash
# Edite os arquivos necessários
# Teste suas mudanças localmente
# Commite com mensagem descritiva

git add .
git commit -m "feat: adiciona documentação do SemGrep como nova ferramenta

- Cria docs/SEMGREP.md com instalação e exemplos
- Adiciona job semgrep à pipeline GitHub Actions
- Atualiza README com nova ferramenta na tabela
- Adiciona exemplo de regras customizadas"
```

**4. Abra o Pull Request**
```markdown
## Descrição
Descreva o que foi adicionado/corrigido.

## Tipo de mudança
- [ ] 🐛 Bug fix
- [ ] ✨ Nova feature
- [ ] 📖 Documentação
- [ ] 🔧 Refatoração
- [ ] 🔒 Segurança

## Impacto
Quais arquivos foram alterados e por quê.

## Testes realizados
Como você testou as mudanças?
- Executou pipeline localmente?
- Testou cada ferramenta afetada?

## Checklist
- [ ] Código comentado em português
- [ ] Documentação atualizada se necessário
- [ ] Vulnerabilidades de exemplo marcadas com `⚠️`
- [ ] README atualizado se adicionou nova feature
```

### Critérios para merge:
- ✅ Revisão de pelo menos 1 maintainer
- ✅ Pipeline de CI passando (ou failing de forma esperada)
- ✅ Documentação atualizada
- ✅ Sem conflitos com main

---

## 🔧 Como Adicionar Novas Ferramentas

Quer adicionar mais uma ferramenta de segurança? Siga este checklist:

### 1. Crie a documentação
```
docs/NOME-FERRAMENTA.md
```

Estrutura mínima do documento:
- O que é a ferramenta
- Como instalar (múltiplos métodos)
- Comandos principais
- Exemplos práticos
- Links úteis

### 2. Adicione o job na pipeline

No arquivo `.github/workflows/unified-security-pipeline.yaml`:
```yaml
# Nome do job: nome-ferramenta
nome-ferramenta:
  name: 🔧 Nome - Descrição
  runs-on: ubuntu-latest
  continue-on-error: true

  steps:
    - name: 📥 Checkout do código
      uses: actions/checkout@v4

    # Instalação manual (sem actions prontas)
    - name: 📦 Instalar Nome manualmente
      run: |
        echo "::group::Instalando Nome"
        # Seu comando de instalação aqui
        echo "::endgroup::"

    - name: 🔍 Nome - Scan
      run: |
        echo "::group::Nome - Scan"
        # Seu comando de scan
        echo "::endgroup::"

    - name: 💾 Salvar relatório
      uses: actions/upload-artifact@v4
      with:
        name: nome-ferramenta-results
        path: nome-ferramenta-report.*
```

### 3. Adicione ao job de resumo

No job `security-summary`, adicione à tabela:
```yaml
echo "| 🔧 Nome | Tipo | ${{ needs.nome-ferramenta.result }} | Descrição |" >> $GITHUB_STEP_SUMMARY
```

### 4. Atualize o README

- Adicione linha na tabela de ferramentas
- Adicione seção em "Como Usar"
- Adicione em "Resultados Esperados"
- Adicione link na tabela de "Links Úteis"

---

## 📖 Como Melhorar a Documentação

A documentação é tão importante quanto o código! Melhorias bem-vindas:

### O que melhorar:
- ✏️ Corrigir erros de português ou digitação
- ➕ Adicionar exemplos práticos que faltam
- 🖼️ Adicionar screenshots ou diagramas
- 🔗 Adicionar links para recursos externos relevantes
- 🌍 Traduzir para inglês (para alcance maior)
- 📊 Melhorar tabelas com mais informações

### Como testar sua documentação:
```bash
# Instale um preview de Markdown local (opcional)
npm install -g markdownlint-cli

# Verifica errros de formatação
markdownlint docs/*.md README.md

# Preview local (opcional)
npx serve .  # abre um servidor local
```

---

## 📬 Contato

- **GitHub Issues**: Para bugs e features
- **Pull Requests**: Para contribuições diretas
- **Discussions**: Para perguntas e conversas gerais

---

Obrigado por contribuir! 🙏  
Juntos fazemos a segurança mais acessível para todos.
