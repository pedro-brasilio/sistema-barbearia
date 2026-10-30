# Modelo lógico e físico do banco

## Modelo lógico

As entidades do sistema são cliente, barbeiro, serviço, agendamento, associação de serviço ao agendamento, produto e pagamento. Um cliente pode realizar vários agendamentos, e um barbeiro pode atender vários agendamentos. A associação entre agendamentos e serviços é representada por uma entidade intermediária. Um pagamento está vinculado a um agendamento. Produtos possuem preço e quantidade em estoque.

No fluxo atual, o agendamento também registra os serviços em uma descrição textual. A existência da entidade intermediária não significa que todas as telas a utilizem para gravar os itens do atendimento.

## Modelo físico das tabelas originais

Os nomes abaixo respeitam as propriedades e migrations existentes, inclusive diferenças de capitalização. Todas as colunas listadas são obrigatórias, exceto `TokenPush`.

| Tabela | Colunas e tipos PostgreSQL | Chave primária |
|---|---|---|
| `clientes` | `id integer`, `Nome text`, `Telefone text`, `Email text`, `senha text`, `IsAdmin boolean`, `TokenPush text` opcional | `id`, identidade |
| `barbeiros` | `id integer`, `Nome text`, `Telefone text` | `id`, identidade |
| `servicos` | `ID integer`, `NameServico text`, `Preco numeric`, `DuracaoMinutos integer` | `ID`, identidade |
| `Agendamentos` | `id integer`, `Clienteid integer`, `Barbeiroid integer`, `Servicos text`, `Data date`, `Situacao text`, `DataHorainicio time without time zone` | `id`, identidade |
| `agendamentoservicos` | `id integer`, `Agendamentoid integer`, `Servicoid integer` | `id`, identidade |
| `produtos` | `Id integer`, `NomeProduto text`, `PrecoProduto numeric`, `EstoqueAtual integer` | `Id`, identidade |
| `pagamentos` | `ID integer`, `Agendamentoid integer`, `ValorTotal numeric`, `DataPagamento timestamp without time zone` | `ID`, identidade |

O termo identidade indica geração automática do identificador pelo PostgreSQL (`IdentityByDefaultColumn`). A senha é armazenada como hash BCrypt; o token push é omitido na serialização pública do modelo.

## Relações lógicas e restrições físicas

| Coluna de referência | Destino lógico | Estado das migrations originais |
|---|---|---|
| `Agendamentos.Clienteid` | `clientes.id` | Identificador escalar; sem FK declarada |
| `Agendamentos.Barbeiroid` | `barbeiros.id` | Identificador escalar; sem FK declarada |
| `agendamentoservicos.Agendamentoid` | `Agendamentos.id` | Identificador escalar; sem FK declarada |
| `agendamentoservicos.Servicoid` | `servicos.ID` | Identificador escalar; sem FK declarada |
| `pagamentos.Agendamentoid` | `Agendamentos.id` | Identificador escalar; sem FK declarada |

As migrations originais contêm chaves primárias, mas não impõem essas relações como chaves estrangeiras nem criam índices para os identificadores de referência. Por isso, o DER lógico e o esquema físico devem ser identificados separadamente. A adição de restrições aos dados legados requer uma migration que verifique registros órfãos e a compatibilidade das operações existentes.

As restrições específicas de novos objetos, como a agenda semanal, devem ser descritas junto de sua migration e não generalizadas para as tabelas legadas.

## Evolução e script operacional

A sequência original é `20261006005356_InitialCreate` e `20261007144107_TokenPushCliente`. O inicializador da API executa `Database.Migrate()` antes de inserir os registros iniciais. Alterações posteriores devem ser entregues por novas migrations, preservando a sequência de atualização de bancos existentes.

O script PostgreSQL da versão entregue deve conter a mesma estrutura e os mesmos objetos das migrations. O script SQL Server da raiz é histórico; a execução dele em PostgreSQL não é o procedimento de instalação do sistema atual.

## Agenda semanal da revisão

A migration `20261030183451_AgendaSemanal` acrescenta `agenda_semanal`, com `agendamento_id integer` e `inicio_semana date`. O identificador é simultaneamente PK e FK para `Agendamentos.id`, com exclusão em cascata. O índice `IX_agenda_semanal_inicio_semana` apoia a consulta semanal. A tabela armazena a classificação temporal sem copiar os demais dados do atendimento. A procedure, a função de trigger e as regras de sincronização estão descritas em [Agenda semanal](agenda_semanal.md).

O script operacional da revisão é [database/Barbearia.PostgreSQL.sql](../../database/Barbearia.PostgreSQL.sql). A documentação das tabelas originais acima permanece válida; o novo vínculo com FK é específico da agenda.
