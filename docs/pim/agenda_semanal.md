# Agenda semanal, procedure e gatilho AFTER

## Objetivo e representação

A agenda semanal classifica os agendamentos por semana, permitindo ao administrador consultar um intervalo de segunda-feira a domingo. A tabela `agenda_semanal` contém somente o identificador do agendamento e a data da segunda-feira da semana. Nome do cliente, telefone, serviços, data, horário e situação continuam na fonte original e são obtidos por consulta, evitando duplicar os dados do atendimento.

| Objeto | Finalidade |
|---|---|
| `agenda_semanal` | Relaciona cada agendamento à semana correspondente |
| `sp_atualizar_agenda_semanal` | Sincroniza um agendamento ou reconcilia toda a agenda |
| `fn_sincronizar_agenda_semanal` | Função chamada pelo gatilho para executar a sincronização |
| `trg_agendamentos_agenda_semanal` | Gatilho AFTER de inserção e de alteração de data/situação |
| `GET /api/Agedamentocontrolador/semana` | Consulta administrativa dos atendimentos da semana |

## Modelo físico

A tabela `public.agenda_semanal` possui:

- `agendamento_id integer`: chave primária e chave estrangeira para `public."Agendamentos".id`;
- `inicio_semana date`: data da segunda-feira que inicia a semana;
- índice `IX_agenda_semanal_inicio_semana`, utilizado para localizar os registros do intervalo;
- exclusão em cascata: ao excluir um agendamento, sua classificação semanal também é removida.

A chave primária garante no máximo uma classificação semanal por agendamento. A FK dessa nova tabela é uma restrição física; ela não significa que todos os relacionamentos das tabelas legadas já possuam FKs.

## Funcionamento do gatilho

O gatilho é declarado como `AFTER INSERT OR UPDATE OF "Data", "Situacao"` na tabela `public."Agendamentos"`, para cada linha. Assim, ele é acionado depois de uma inserção ou de uma atualização que inclua as colunas de data ou situação. Sua execução faz parte da mesma transação que modifica o agendamento.

A função `fn_sincronizar_agenda_semanal` chama `sp_atualizar_agenda_semanal(NEW.id)`. A procedure calcula a segunda-feira com o dia ISO da semana e insere a classificação. Se o agendamento já estiver classificado, atualiza a semana por meio de `ON CONFLICT`. Agendamentos com situação `cancelado` são removidos da classificação.

O comportamento esperado é:

| Operação no agendamento | Efeito na agenda |
|---|---|
| Criar como pendente | Incluir na semana da data escolhida |
| Confirmar | Preservar a classificação da semana |
| Alterar para outra semana | Atualizar a segunda-feira de referência |
| Alterar a situação para cancelado | Remover da classificação semanal |
| Reativar um registro cancelado | Incluir novamente na semana correspondente |
| Excluir | Remover a classificação pela FK com cascata |

O cancelamento feito atualmente pelo endpoint DELETE exclui o registro; portanto, nesse fluxo, a remoção semanal ocorre por cascata. A alteração da situação para `cancelado`, quando realizada por atualização, é tratada pelo gatilho.

Não se cria um novo trigger a cada agendamento: o objeto é instalado pela migration e atua sobre as operações seguintes. Durante a instalação, uma chamada sem identificador reconcilia os agendamentos anteriores, incluindo os registros existentes na agenda.

## Procedure e reconciliação

A assinatura é `public.sp_atualizar_agenda_semanal(p_agendamento_id integer DEFAULT NULL)`. Um identificador restringe a sincronização ao respectivo agendamento. O valor NULL reconcilia todos os registros ativos e remove classificações sem correspondência válida.

Para reconciliar a agenda inteira:

```sql
CALL public.sp_atualizar_agenda_semanal();
```

A sincronização por identificador bloqueia a linha de origem para coordenar chamadas manuais concorrentes. A reconciliação completa utiliza um bloqueio de manutenção na tabela. Ela não apaga o histórico de agendamentos nem duplica as informações pessoais dos clientes.

## Consulta pela API

O endpoint recebe uma data opcional no formato `YYYY-MM-DD`. Ele calcula a segunda-feira e o domingo da semana que contém essa data. Se o parâmetro for omitido, utiliza a data atual do servidor. A autorização exige o papel de administrador.

Exemplo:

```http
GET /api/Agedamentocontrolador/semana?data=2026-10-30
Authorization: Bearer TOKEN_DA_SESSAO
```

Nesse exemplo, o intervalo é de 26 de outubro a 1º de novembro de 2026. A resposta contém `inicioSemana`, `fimSemana` e `agendamentos`, ordenados por data, horário e identificador. Os registros incluem o nome e o telefone do cliente para a apresentação administrativa. Requisições sem autenticação ou de cliente comum não possuem acesso à agenda completa.

A atualização no banco é automática pelo trigger. A atualização visual depende de uma nova consulta da interface; o gatilho não envia, por si só, um evento ao navegador ou ao aplicativo.

## Artefatos e verificação

A implementação está na migration `20261030183451_AgendaSemanal`, no modelo `AgendaSemanal`, na configuração de `Barbeariacontext` e no método `semana` do controlador de agendamentos. O [script PostgreSQL](../../database/Barbearia.PostgreSQL.sql) reúne a estrutura operacional. Os casos de teste devem verificar inserção, confirmação, mudança de semana, cancelamento, exclusão, reconciliação e autorização.

Os resultados executados devem ser apresentados com comando, ambiente, versão e saída. A descrição dos casos não equivale à comprovação de que todos passaram.

Os resultados executados da revisão de 30 de outubro de 2026 estão em [Resultados das verificações](resultados_testes.md), incluindo evolução das migrations, testes SQL, API, site e aplicativo.
