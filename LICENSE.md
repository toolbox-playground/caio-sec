MIT License

Copyright (c) 2026 Toolbox Playground

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## Nota sobre os Exemplos Vulneráveis

Os arquivos localizados em `examples/` contêm **vulnerabilidades intencionais** criadas
exclusivamente para fins educacionais e demonstração das ferramentas de segurança.

- `examples/python/app.py` — Código Python com vulnerabilidades documentadas
- `examples/python/Dockerfile` — Dockerfile com misconfigurations intencionais
- `examples/terraform/main.tf` — Infraestrutura Terraform insegura por design
- `examples/secrets/vulnerable-sample.env` — Credenciais **falsas** para teste de detecção

**AVISO**: Nunca utilize estes exemplos como base para código de produção.
As credenciais presentes são fictícias e usadas apenas para demonstrar detecção de segredos.

Este repositório é um projeto educacional do **Toolbox Playground** para ensinar
boas práticas de DevSecOps de forma prática e acessível.
