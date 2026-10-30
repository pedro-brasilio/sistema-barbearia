# Matriz de requisitos e evidências do código

Esta matriz permite localizar a implementação. Ela não substitui registros de execução dos testes nem a demonstração do sistema.

| Tema solicitado no PIM | Evidência existente | Arquivos principais | Complemento necessário |
|---|---|---|---|
| Aplicação web | React, cliente HTTP, telas de agendamento e administração | `frontend/src/App.tsx`, `frontend/src/api.ts`, `frontend/src/pages/` | Capturas identificadas e demonstração |
| API e autenticação | Endpoints REST, JWT e controle de acesso | `backend/Controllers/`, `backend/seguranca/tokens.cs`, `backend/barbearia.cs` | Registrar testes de permissões e corrigir recuperação de senha |
| Aplicativo móvel | Flutter, modelos, chamadas HTTP e navegação | `mobile/lib/app.dart`, `mobile/lib/api.dart`, `mobile/lib/pages/` | Capturas do APK e ambiente utilizado |
| Agenda semanal e trigger AFTER | Classificação por semana, procedure, trigger e consulta autorizada | `backend/Migrations/20261030183451_AgendaSemanal.cs`, `backend/Controllers/Agedamentocontrolador.cs`, `database/Barbearia.PostgreSQL.sql` | Registrar resultados do banco, API e interface |
| Banco lógico/físico | Modelos C#, migrations e tipos PostgreSQL | `backend/modelos/`, `backend/dados/barbeariacontext.cs`, `backend/Migrations/` | Script atual, objetos SQL e distinção das relações lógicas |
| Orientação a objetos | Classes de modelo, herança de DbContext e injeção de dependência | `backend/modelos/`, `backend/dados/`, `backend/barbearia.cs` | Explicar responsabilidades e limites das camadas |
| Nuvem | Banco, API Docker e site descritos como infraestrutura | `render.yaml`, `backend/Dockerfile` | Plano de escalabilidade e evidências do ambiente |
| Entrega do Android | Workflow de geração, assinatura e publicação do APK | `.github/workflows/app-android.yml` | Resultado da execução e versão gerada |
| Testes do aplicativo | Testes de widgets e API simulada | `mobile/test/` | Comando, resultado e log da execução |
| Notificações | Registro do token, seleção de público e workflow FCM | `mobile/lib/push.dart`, `backend/Controllers/Notificacaocontrolador.cs`, `n8n/notificacoes-push.json` | Demonstração do envio no ambiente configurado |
| Gestão ágil | Há divisão por módulos e histórico no controle de versão | Estrutura do repositório e commits | Backlogs, Kanban, responsáveis e datas reais |
| Empreendedorismo | Produto e funcionalidades são identificáveis no repositório | `README.md`, interfaces e API | Organização de referência, validação e viabilidade |
| Diversidade e inclusão | Widget VLibras no site e possibilidade de catálogo de serviços variado | `frontend/src/pages/`, `frontend/src/components/`, `frontend/index.html` | Descrever ações concretas e fontes do contexto social |

A ausência de um artefato nesta matriz não prova inexistência fora do repositório. Dados de pesquisa, organização, custos e decisões do grupo precisam de fontes próprias.
