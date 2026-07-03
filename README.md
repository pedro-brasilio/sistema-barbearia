# Sistema de Barbearia

Projeto acadêmico desenvolvido para a disciplina de Projeto Integrado Multidisciplinar (PIM), com o objetivo de aplicar conceitos de desenvolvimento em C# e modelagem de banco de dados relacional.

O sistema foi pensado para apoiar a organização de uma barbearia, centralizando informações de clientes, barbeiros, serviços, agendamentos, produtos e pagamentos.

## Funcionalidades

- Cadastro de clientes;
- Cadastro de barbeiros;
- Cadastro de serviços, com preço e duração;
- Controle de agendamentos;
- Registro da situação dos agendamentos: pendente, confirmado ou cancelado;
- Associação de serviços aos agendamentos;
- Cadastro e controle básico de estoque de produtos;
- Registro de pagamentos vinculados aos agendamentos.

## Tecnologias utilizadas

- C#
- SQL Server
- Visual Studio 2022
- SQL

## Estrutura do banco de dados

O banco de dados `BarbeariaDB` possui as seguintes tabelas:

- `clientes`
- `barbeiros`
- `servicos`
- `Agendamentos`
- `agendamentoservicos`
- `produtos`
- `pagamentos`

O script também inclui dados iniciais de um barbeiro padrão e serviços para teste.

## Como executar

1. Clone ou baixe este repositório.
2. Abra a solução `PIM3ºSEMESTRE.sln` no Visual Studio.
3. Abra o arquivo `Barbearia.sql` no SQL Server Management Studio ou em outra ferramenta compatível com SQL Server.
4. Execute o script para criar o banco de dados `BarbeariaDB`.
5. Verifique e configure a string de conexão do projeto, caso necessário.
6. Execute o projeto pelo Visual Studio.

> **Atenção:** no final do arquivo `Barbearia.sql` existe um comando para excluir o banco de dados (`DROP DATABASE BarbeariaDB`). Remova ou comente esse trecho antes de executar o script em um ambiente onde deseja manter os dados.

## Autores

- Pedro Luciano Brasilio dos Santos
- Moises Gomes
- Luis Laia
- João Victor

## Finalidade acadêmica

Este projeto foi desenvolvido exclusivamente para fins acadêmicos, como parte de um trabalho de faculdade.
