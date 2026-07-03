-- ============================================
-- CRIA O BANCO
-- ============================================
CREATE DATABASE BarbeariaDB;
GO

USE BarbeariaDB;
GO

-- ============================================
-- CLIENTES
-- ============================================
CREATE TABLE clientes (
    id        INT PRIMARY KEY IDENTITY,
    Nome      VARCHAR(100) NOT NULL,
    Telefone  VARCHAR(20)  NOT NULL,
    Email     VARCHAR(100) NOT NULL UNIQUE,
    senha     VARCHAR(255) NOT NULL,
    IsAdmin   BIT          NOT NULL DEFAULT 0
);
GO

-- ============================================
-- BARBEIROS
-- ============================================
CREATE TABLE barbeiros (
    id       INT PRIMARY KEY IDENTITY,
    Nome     VARCHAR(100) NOT NULL,
    Telefone VARCHAR(20)  NOT NULL
);
GO

-- ============================================
-- SERVIÇOS
-- ============================================
CREATE TABLE servicos (
    ID               INT PRIMARY KEY IDENTITY,
    NameServico      VARCHAR(100)   NOT NULL,
    Preco            DECIMAL(10,2)  NOT NULL,
    DuracaoMinutos   INT            NOT NULL
);
GO

-- ============================================
-- AGENDAMENTOS
-- ============================================
CREATE TABLE Agendamentos (
    id              INT PRIMARY KEY IDENTITY,
    Clienteid       INT          NOT NULL,
    Barbeiroid      INT          NOT NULL,
    Servicos        VARCHAR(100) NOT NULL,
    Data            DATE         NOT NULL,
    DataHorainicio  TIME         NOT NULL,
    Situacao        VARCHAR(20)  NOT NULL DEFAULT 'pendente'
        CHECK (Situacao IN ('pendente', 'confirmado', 'cancelado')),
    FOREIGN KEY (Clienteid)  REFERENCES clientes(id),
    FOREIGN KEY (Barbeiroid) REFERENCES barbeiros(id)
);
GO

-- ============================================
-- AGENDAMENTO SERVIÇOS (tabela de relação)
-- ============================================
CREATE TABLE agendamentoservicos (
    id            INT PRIMARY KEY IDENTITY,
    Agendamentoid INT NOT NULL,
    Servicoid     INT NOT NULL,
    FOREIGN KEY (Agendamentoid) REFERENCES Agendamentos(id),
    FOREIGN KEY (Servicoid)     REFERENCES servicos(ID)
);
GO

-- ============================================
-- PRODUTOS
-- ============================================
CREATE TABLE produtos (
    Id              INT PRIMARY KEY IDENTITY,
    NomeProduto     VARCHAR(100)  NOT NULL,
    PrecoProduto    DECIMAL(10,2) NOT NULL,
    EstoqueAtual    INT           NOT NULL DEFAULT 0
);
GO

-- ============================================
-- PAGAMENTOS
-- ============================================
CREATE TABLE pagamentos (
    ID              INT PRIMARY KEY IDENTITY,
    Agendamentoid   INT           NOT NULL,
    ValorTotal      DECIMAL(10,2) NOT NULL,
    DataPagamento   DATETIME      NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (Agendamentoid) REFERENCES Agendamentos(id)
);
GO

-- ============================================
-- BARBEIRO PADRÃO (necessário para agendamentos)
-- ============================================
INSERT INTO barbeiros (Nome, Telefone)
VALUES ('Barbeiro Principal', '(11) 99999-9999');
GO

-- ============================================
-- SERVIÇOS PADRÃO
-- ============================================
INSERT INTO servicos (NameServico, Preco, DuracaoMinutos) VALUES
('Corte Clássico',    45.00, 30),
('Corte + Barba',     70.00, 50),
('Barba Tradicional', 35.00, 20),
('Corte Premium',     80.00, 45);
GO

USE BarbeariaDB;
SELECT * FROM clientes;

USE master;
GO
ALTER DATABASE BarbeariaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE BarbeariaDB;
GO
