# Planejamento da revisão do PIM

Este é um plano de trabalho para a revisão atual. Ele não reconstrói nem afirma que os quadros foram utilizados em sprints passadas. O grupo deve confirmar responsáveis, estimativas e datas antes de adotá-lo.

## Product Backlog proposto

| ID | Prioridade | Objetivo | Entrega verificável |
|---|---|---|---|
| PB01 | Alta | Agendamento refletido na agenda semanal | Trigger, estrutura de agenda, consulta pela API e apresentação ao administrador |
| PB02 | Alta | Consistência da agenda | Atualização/cancelamento/exclusão refletidos e casos de teste |
| PB03 | Alta | Entrega do banco PostgreSQL | Script correspondente às migrations, objetos SQL e instruções |
| PB04 | Alta | Segurança da recuperação de senha | Comprovação da posse da conta antes da alteração e testes |
| PB05 | Alta | Evidência de qualidade | Testes executados, resultados e correção de falhas |
| PB06 | Média | Rastreabilidade da documentação | Matriz de requisitos, modelos e descrição dos fluxos reais |
| PB07 | Média | Operação e crescimento | Monitoramento e plano de escalabilidade |
| PB08 | Média | Validação do negócio | Caracterização da organização, pesquisa e viabilidade confirmadas pelo grupo |

## Sprint Backlog proposto

A meta é entregar uma versão verificável da agenda semanal e seus artefatos de banco, acompanhada da documentação e dos resultados de teste. Os itens abaixo devem ser atualizados conforme a execução real.

| Item | Tarefa | Dependência | Critério de conclusão |
|---|---|---|---|
| SB01 | Definir contrato da agenda e início/fim da semana | PB01 | Regra de intervalo e formato documentados |
| SB02 | Criar migration e objetos SQL | SB01 | Instalação em banco vazio e atualização de banco existente verificadas |
| SB03 | Integrar consulta de agenda na API | SB02 | Autorização e dados da semana conferidos |
| SB04 | Integrar apresentação semanal | SB03 | Fluxo web/aplicativo compatível com a API |
| SB05 | Testar alterações da agenda | SB02–SB04 | Inserção, alteração, cancelamento e exclusão com resultados registrados |
| SB06 | Gerar script PostgreSQL e documentação | SB02 | Script coerente com a migration e instruções executáveis |
| SB07 | Executar verificações do projeto | SB03–SB06 | Resultados reais de build/testes publicados |
| SB08 | Revisar texto acadêmico | SB05–SB07 | Funcionalidades descritas conforme o código e evidências |

## Kanban proposto

As colunas de acompanhamento são A fazer, Em andamento, Em revisão e Concluído. O cartão deve conter o ID do backlog, tarefa, responsável escolhido pelo grupo, versão/commit e evidência. A passagem para Concluído exige o critério de aceitação; a simples existência de código não comprova execução bem-sucedida.

O estado inicial de planejamento dos itens é A fazer. Este documento não atribui estados históricos. Durante a revisão, o grupo pode registrar no quadro as atividades que estão efetivamente em execução e as entregas já verificadas.

## Definição de pronto

- Funcionalidade e autorização conferidas no ambiente de teste.
- Alterações de banco entregues por migration e com instalação documentada.
- Casos relevantes executados e resultados registrados.
- Contratos web/mobile compatíveis.
- Texto atualizado com limitações conhecidas.
- Segredos ausentes dos artefatos públicos.

## Cronograma

O grupo deve vincular os itens a datas de início e fim e a responsáveis reais. A tabela de sprints do trabalho original pode ser mantida como histórico somente para atividades e períodos que o grupo consiga comprovar. Este plano não fornece datas retroativas.
