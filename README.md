# Sistema de Barbearia

Projeto acadêmico desenvolvido para a disciplina de Projeto Integrado Multidisciplinar (PIM), com o objetivo de aplicar conceitos de desenvolvimento back-end em C#, front-end em React e modelagem de banco de dados relacional.

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

## Estrutura do projeto

```
sistema-barbearia/
├── backend/          # API em C# (.NET) + Entity Framework Core
├── frontend/         # Interface web em React + TypeScript + Vite
├── Barbearia.sql     # Script de criação do banco de dados
└── PIM3ºSEMESTRE.sln # Solução do Visual Studio
```

## Tecnologias utilizadas

**Back-end**
- C# / .NET
- Entity Framework Core
- SQL Server

**Front-end**
- React
- TypeScript
- Vite

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

### Banco de dados

1. Abra o arquivo `Barbearia.sql` no SQL Server Management Studio ou em outra ferramenta compatível com SQL Server.
2. Execute o script para criar o banco de dados `BarbeariaDB`.

> **Atenção:** no final do arquivo `Barbearia.sql` existe um comando para excluir o banco de dados (`DROP DATABASE BarbeariaDB`). Remova ou comente esse trecho antes de executar o script em um ambiente onde deseja manter os dados.

### Back-end (API)

1. Abra a solução `PIM3ºSEMESTRE.sln` no Visual Studio, ou navegue até a pasta `backend/`.
2. Verifique e configure a string de conexão em `appsettings.json`, caso necessário.
3. Execute o projeto (Visual Studio ou `dotnet run` dentro de `backend/`).

### Front-end

```bash
cd frontend
npm install
npm run dev
```

## Autores

- Pedro Luciano Brasilio dos Santos
- Moises Gomes
- Luis Laia
- João Victor

## Finalidade acadêmica

Este projeto foi desenvolvido exclusivamente para fins acadêmicos, como parte de um trabalho de faculdade.
