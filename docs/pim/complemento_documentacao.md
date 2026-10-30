# Complemento acadêmico da documentação

## Arquitetura e orientação a objetos

A solução é composta por uma API REST em C# com ASP.NET Core, uma interface web em React e um aplicativo em Flutter. As duas interfaces utilizam a mesma API e o mesmo banco PostgreSQL. Essa organização centraliza as regras de negócio e permite reutilizar as operações entre navegador e aplicativo.

A API utiliza classes para representar os dados do domínio: `Agendamento`, `cliente`, `barbeiro`, `servico`, `agendamentoservico`, `produto` e `pagamento`. A classe `Barbeariacontext` herda de `DbContext` e expõe conjuntos `DbSet` utilizados nas consultas e alterações. A injeção de dependência fornece o contexto aos controladores e configura o componente `Tokens`, responsável pela emissão e leitura das credenciais JWT.

Os controladores recebem requisições HTTP, verificam permissões e coordenam o acesso à persistência. O controlador de agendamentos aplica o limite mensal, verifica ocupação do horário e define a situação inicial como pendente. A organização em diretórios separa controladores, modelos, acesso a dados e segurança. Na implementação de referência, as regras permanecem principalmente nos controladores; não há uma camada independente de serviços de domínio.

A divisão de responsabilidades é complementada nas interfaces por componentes de apresentação, modelos de dados e clientes HTTP. Em Flutter, `AppShell` mantém o estado da sessão e encaminha ações aos métodos de `Api`. No site, `App.tsx` coordena a navegação, o usuário autenticado e as listas carregadas por `api.ts`.

## Integração entre web, aplicativo e banco

O cadastro e o login devolvem os dados do usuário e um token JWT. O token é mantido na memória da sessão e enviado no cabeçalho `Authorization` das chamadas protegidas. O administrador consulta a agenda completa; o cliente consulta os registros vinculados ao próprio identificador. A API aplica as permissões, independentemente do que a interface apresenta.

A criação, a confirmação e a exclusão de agendamentos são enviadas à API e persistidas no PostgreSQL. Após as operações, as interfaces recarregam os dados. Também há atualização ao autenticar, navegar entre telas e na virada do dia. Assim, alterações realizadas em um cliente podem ser consultadas pelo outro no próximo carregamento.

A atualização entre aparelhos ocorre por novas consultas HTTP. A versão de referência não utiliza WebSocket ou SignalR para propagar alterações instantaneamente. A distinção evita confundir a persistência compartilhada com atualização em tempo real.

## Persistência e evolução do esquema

O esquema inicial é criado pela migration `InitialCreate`, e a migration `TokenPushCliente` acrescenta o token opcional usado para notificações. O inicializador aplica as migrations e insere registros iniciais quando ainda não existem: barbeiro principal, serviços e administrador configurado.

A data de agendamento é armazenada em `date`, e o horário em `time without time zone`. O pagamento utiliza `timestamp without time zone`. O modelo lógico relaciona clientes e barbeiros aos agendamentos; serviços podem ser associados por uma tabela intermediária; pagamentos referenciam agendamentos. A descrição detalhada dos atributos e das restrições efetivamente implementadas está no [modelo de dados](modelo_dados.md).

O arquivo `Barbearia.sql` representa a modelagem original em SQL Server. Ele é uma referência histórica e não deve ser usado como script operacional do PostgreSQL. A entrega do banco deve corresponder às migrations e aos objetos SQL efetivamente utilizados pela versão da aplicação.

## Agenda semanal e processamento no banco

A revisão acrescenta a classificação automática dos agendamentos em semanas de segunda-feira a domingo. Após inserir um atendimento, um gatilho AFTER executa uma função que chama a procedure de sincronização. A tabela de agenda mantém uma única referência ao agendamento e à semana, enquanto os dados do atendimento permanecem na tabela original. Mudanças de data atualizam a classificação; o cancelamento retira o atendimento da agenda; a exclusão do registro elimina sua referência por uma FK com cascata.

A consulta administrativa `GET /api/Agedamentocontrolador/semana` recebe uma data de referência e devolve o intervalo e os atendimentos correspondentes. A migration também reconcilia os registros anteriores à instalação do gatilho. O detalhamento do modelo, dos eventos e da procedure está em [Agenda semanal](agenda_semanal.md). A funcionalidade deve ser acompanhada dos resultados das verificações realizadas no banco e na API.

## Estratégia de testes e evidências

O aplicativo contém testes de widgets que verificam a tela inicial, a exigência de login para agendar, a validação de senha no cadastro, o acesso às abas administrativas, o formulário de notificações, a gestão de serviços e a apresentação dos perfis. Parte dos testes usa `ApiFalsa` e `MockClient`, fornecendo respostas controladas sem acessar a rede.

Esses testes avaliam a interface e o contrato esperado da API. Eles não demonstram, isoladamente, a gravação no PostgreSQL ou a aplicação das permissões no servidor. Para comprovar a integração, são necessárias verificações da API e do banco, acompanhadas de resultados e evidências.

No relatório de execução, cada caso deve distinguir objetivo, condição inicial, entrada, resultado esperado, resultado obtido, situação e evidência. Casos ainda não executados permanecem identificados como planejados. O código de um teste demonstra sua existência; o resultado de execução demonstra seu comportamento no ambiente e na versão registrados.

## Infraestrutura e entrega

O arquivo `render.yaml` declara um banco PostgreSQL, uma API em contêiner Docker e um site estático. A configuração da API recebe a conexão a partir do recurso de banco. As origens CORS e o endereço da API usado pelo frontend são configuráveis, e credenciais de produção são recebidas por variáveis e secrets.

Os filtros de build da API e do site selecionam mudanças nos respectivos diretórios. O fluxo Android prepara o ambiente Flutter e Java, instala dependências e gera o APK. O artefato pode ser disponibilizado nas execuções do workflow; a publicação em Releases ocorre na branch principal, usando a chave de assinatura configurada.

A rota de catálogo de serviços é utilizada como verificação de saúde da API. Ela exercita uma consulta necessária ao funcionamento do sistema, mas não substitui logs, indicadores, alertas e testes completos. O [plano de escalabilidade](viabilidade_e_escalabilidade.md) distingue recursos existentes de evoluções propostas.

## Limites da validação com questionários

O preenchimento de um questionário pelo grupo com um respondente fictício verifica aspectos básicos do formulário, como campos, clareza inicial e envio. Esse procedimento não representa a opinião de clientes reais nem comprova a demanda de mercado. Caso a pesquisa de campo ainda não tenha ocorrido, a documentação deve apresentar o instrumento como preparado para aplicação futura. Resultados de entrevistas ou questionários reais devem ser acompanhados do procedimento de coleta, quantidade de participantes e análise.

## Resultados da revisão

Na revisão de 30 de outubro de 2026, a API compilou com zero erros, o script PostgreSQL foi aplicado duas vezes sem erro, dez grupos de testes SQL e 27 asserções de integração da API foram aprovados. O site compilou e passou em dois testes; o aplicativo passou em 15 testes, incluindo seis novos da agenda. A atualização de um banco com dados anteriores, o downgrade e a reaplicação da migration também foram verificados. Os comandos e limites desses resultados estão em [Resultados das verificações](resultados_testes.md).
