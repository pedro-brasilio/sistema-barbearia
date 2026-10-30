# Viabilidade e escalabilidade

## Análise de viabilidade proposta

O sistema oferece agendamento por navegador e aplicativo e administração de serviços e comunicação. Para avaliar sua viabilidade comercial, é necessário estimar receita, custo fixo, custo variável e esforço de suporte. A presença de uma aplicação funcional demonstra uma solução técnica; não comprova, isoladamente, rentabilidade ou disposição dos clientes em pagar.

| Componente | Informação a levantar | Como utilizar |
|---|---|---|
| Hospedagem | Plano da API, banco e disponibilidade necessária | Custo fixo mensal e capacidade |
| Manutenção | Horas de atualização, correções e suporte | Custo de operação por período |
| Mensagens e serviços | Limites e cobrança dos fornecedores | Custo variável conforme o uso |
| Receita | Mensalidade proposta, implantação e clientes previstos | Receita por cenário |
| Adoção | Interesse real, forma atual de agendar e dificuldades | Validação da proposta de valor |
| Risco | Indisponibilidade, perda de dados e dependência de serviços | Reserva, contingência e prioridades |

Um modelo de simulação pode utilizar:

- Receita mensal = número de barbearias contratantes × mensalidade.
- Custo mensal = custos fixos + custos variáveis + manutenção e suporte.
- Resultado operacional estimado = receita mensal − custo mensal.
- Ponto de equilíbrio, quando aplicável = custo fixo ÷ margem de contribuição por contratante.

O ponto de equilíbrio depende de margem positiva e premissas consistentes. Valores simulados devem ser identificados como simulação; preços e condições consultados precisam de fonte e data. Este documento não atribui valores não pesquisados nem apresenta estimativas como resultados de mercado.

## Infraestrutura atual

A API, o site e o banco são declarados em `render.yaml`. O banco é acessado pelo Npgsql/Entity Framework Core; a API é empacotada em Docker; o site é construído como conteúdo estático. As variáveis recebem a conexão, origens permitidas e credenciais. O endpoint de serviços é utilizado como health check.

A documentação do projeto registra limitações de planos gratuitos. A disponibilidade e as condições atuais dos fornecedores precisam ser verificadas no momento da implantação; a estratégia deve ser dimensionada para as necessidades da organização.

## Plano de crescimento proposto

1. Medir volume de requisições, latência, falhas, uso de conexões e consultas mais frequentes. Definir objetivos de desempenho com a organização antes de escolher limiares.
2. Otimizar as consultas de agenda por intervalo de datas e verificar índices e plano de execução. Evitar transferir todo o histórico quando apenas uma semana for necessária.
3. Dimensionar API e banco a partir das medições e do custo permitido. Separar necessidades de processamento, armazenamento e conexões.
4. Adotar cópias de segurança e testar restauração. Registrar retenção e responsáveis conforme o ambiente escolhido.
5. Complementar o health check com logs e alertas. Verificar erros da API, falhas de integração e indisponibilidade de serviços externos.
6. Avaliar múltiplas instâncias da API quando a demanda justificar. Nesse cenário, coordenar a aplicação de migrations como uma etapa de implantação para evitar atualizações simultâneas do esquema.
7. Registrar os resultados de testes de carga antes de afirmar capacidade para determinado número de usuários.

Essas etapas são propostas de evolução. A existência de contêiner, CI ou serviço em nuvem não significa que escalabilidade automática, backups ou testes de carga já estejam configurados.
