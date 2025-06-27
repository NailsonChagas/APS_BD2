CREATE TABLE Clientes (
    cpf_cnpj VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200),
    telefone VARCHAR(20),
    email VARCHAR(100),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Fornecedores (
    cnpj VARCHAR(20) PRIMARY KEY,
    nome_empresa VARCHAR(100) NOT NULL,
    localizacao VARCHAR(200),
    contato VARCHAR(100),
    email VARCHAR(100),
    telefone VARCHAR(20),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Produto (
    id_produto VARCHAR(20) PRIMARY KEY,  -- código de barras
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Estoque (
    id_estoque SERIAL PRIMARY KEY,
    id_produto VARCHAR(20) NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    ultima_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
    CONSTRAINT quantidade_nao_negativa CHECK (quantidade >= 0)
);

CREATE TABLE Promocoes (
    id_promocao SERIAL PRIMARY KEY,
    nome_promocao VARCHAR(100),
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP NOT NULL,
    porcentagem DECIMAL(5,2) NOT NULL,
    produtos_em_promocao VARCHAR(20)[] NOT NULL, 
    ativa BOOLEAN DEFAULT TRUE,
    CONSTRAINT porcentagem_valida CHECK (porcentagem > 0 AND porcentagem <= 100),
    CONSTRAINT datas_validas CHECK (data_fim > data_inicio)
);

CREATE TABLE Transacao (
    id_transacao SERIAL PRIMARY KEY,
    id_cliente VARCHAR(20), 
    id_fornecedor VARCHAR(20),  
    tipo_transacao VARCHAR(10) NOT NULL CHECK (tipo_transacao IN ('VENDA', 'COMPRA')),
    valor_total DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento VARCHAR(50),
    observacoes TEXT,
    CONSTRAINT check_correct_reference CHECK (
        (tipo_transacao = 'VENDA' AND id_cliente IS NOT NULL AND id_fornecedor IS NULL) OR
        (tipo_transacao = 'COMPRA' AND id_fornecedor IS NOT NULL AND id_cliente IS NULL)
    ),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(cpf_cnpj),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(cnpj)
);

CREATE TABLE ItemTransacao (
    id_item_transacao SERIAL PRIMARY KEY,
    id_transacao INT NOT NULL,
    id_produto VARCHAR(20) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    preco_total DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    id_promocao INT[],  -- array de ids de promoçoes
    FOREIGN KEY (id_transacao) REFERENCES Transacao(id_transacao),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
    CONSTRAINT quantidade_positiva CHECK (quantidade > 0)
);
