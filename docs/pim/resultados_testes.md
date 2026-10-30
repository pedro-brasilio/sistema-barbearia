# Resultados das verificações da revisão

Revisão técnica de 30 de outubro de 2026. As verificações foram realizadas em ambiente de teste, com PostgreSQL 17.11 e dados sintéticos. Os resultados abaixo se referem à revisão da agenda semanal e às suítes executadas; não representam pesquisa com clientes nem teste de carga em produção.

| Verificação | Comando ou artefato | Resultado observado |
|---|---|---|
| Compilação da API | `dotnet build backend/barbearia.csproj -c Release` | Concluída com zero erros; avisos legados permanecem |
| Instalação do banco | `database/Barbearia.PostgreSQL.sql` aplicado duas vezes com interrupção em erro | Duas aplicações concluídas sem erro |
| Evolução do esquema | Roteiros em `database/tests/migration` | Upgrade com registros anteriores, downgrade e reaplicação aprovados |
| Integração SQL | `psql -v ON_ERROR_STOP=1 -f database/tests/agenda_semanal.sql` em banco de testes | Dez grupos de verificações aprovados |
| Integração da API | `python tests/agenda_api_test.py`, após configurar `PIM_TEST_DB_CONNECTION` para banco isolado | 27 asserções aprovadas |
| Testes do site | `npm test`, no diretório `frontend` | Dois testes aprovados |
| Compilação do site | `npm run build`, no diretório `frontend` | Concluída com sucesso |
| Testes do aplicativo | `flutter test --no-pub --concurrency 1`, no diretório `mobile` | 15 testes aprovados, incluindo seis novos da agenda semanal |

## O que as verificações cobrem

Os testes SQL verificam a classificação do agendamento, fronteiras da semana e do ano, confirmação, remarcação, cancelamento, reativação, exclusão, reconciliação e consistência transacional. O script usa registros de teste e termina com rollback.

O teste de API inicia o servidor real e usa PostgreSQL. Ele cobre ausência de autenticação (401), acesso de cliente comum à agenda administrativa (403), criação seguida de consulta semanal, confirmação, remarcação, cancelamento, reativação, exclusão e data inválida. As contas e os registros de teste são sintéticos e removidos pelo procedimento de limpeza.

Os testes do site e do aplicativo avaliam comportamentos das interfaces e o tratamento da agenda. A aprovação dessas suítes não substitui a demonstração de um APK em dispositivo real nem comprova capacidade de atendimento sob carga.

## Reprodução

A integração deve usar banco de testes isolado. Primeiro compile a API em Release e aplique o esquema. Depois execute o teste SQL e o script de API. A variável `PIM_TEST_DB_CONNECTION` informa a conexão utilizada pelo teste de API; não publique seu valor, tokens ou credenciais nos registros do trabalho.

A compilação do site e a execução dos testes pressupõem dependências instaladas. A opção `--no-pub` do teste Flutter utiliza as dependências já resolvidas no ambiente.

Os roteiros de evolução são `agenda_before.sql`, `agenda_upgrade_seed.sql`, `agenda_upgrade_check.sql`, `agenda_down.sql` e `agenda_down_check.sql`. Após a inclusão dos bloqueios da procedure, os dez grupos SQL e as 27 asserções da API foram executados novamente e aprovados.

A agenda web também foi inspecionada em larguras de 1366 e 390 pixels, sem overflow observado. Essa inspeção usou dados sintéticos e respostas HTTP controladas; ela verifica apresentação e navegação, não substitui a integração com a API real já testada separadamente.
