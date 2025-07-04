CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- CLIENTES
CREATE INDEX idx_clientes_nome ON Clientes (nome);
CREATE INDEX idx_clientes_email ON Clientes (email);

-- FORNECEDORES
CREATE INDEX idx_fornecedores_nome_empresa ON Fornecedores (nome_empresa);

-- PRODUTO
CREATE INDEX idx_produto_nome ON Produto (nome);

-- ESTOQUE
CREATE INDEX idx_estoque_id_produto ON Estoque (id_produto);

-- PROMOCOES
CREATE INDEX idx_promocoes_periodo_ativas ON Promocoes (data_inicio, data_fim) WHERE ativa = TRUE;
CREATE INDEX idx_promocoes_produtos_ativos_gin ON Promocoes USING GIN (produtos_em_promocao) WHERE ativa = TRUE;

-- TRANSACAO
CREATE INDEX idx_transacao_data ON Transacao (data);
CREATE INDEX idx_transacao_id_cliente ON Transacao (id_cliente);
CREATE INDEX idx_transacao_id_fornecedor ON Transacao (id_fornecedor);
CREATE INDEX idx_transacao_cliente_tipo_data ON Transacao (id_cliente, tipo_transacao, data);
CREATE INDEX idx_transacao_fornecedor_tipo_data ON Transacao (id_fornecedor, tipo_transacao, data);
CREATE INDEX idx_transacao_forma_pagamento ON Transacao(forma_pagamento);

-- ITEMTRANSACAO
CREATE INDEX idx_itemtransacao_id_transacao ON ItemTransacao (id_transacao);
CREATE INDEX idx_itemtransacao_id_produto ON ItemTransacao (id_produto);
CREATE INDEX idx_itemtransacao_produto_quantidade ON ItemTransacao(id_produto, quantidade);

ANALYZE Clientes;
ANALYZE Fornecedores;
ANALYZE Estoque;
ANALYZE Promocoes;
ANALYZE Transacao;
ANALYZE ItemTransacao;

SELECT * FROM Clientes;
SELECT COUNT(*) AS total_clientes FROM Clientes;
SELECT * FROM Fornecedores;
SELECT COUNT(*) AS total_Fornecedores FROM Fornecedores;
SELECT * FROM Estoque;
SELECT COUNT(*) AS total_Estoque FROM Estoque;
SELECT * FROM Promocoes;
SELECT COUNT(*) AS total_Promocoes FROM Promocoes;
SELECT * FROM Transacao;
SELECT COUNT(*) AS total_Transacao FROM Transacao;
SELECT * FROM ItemTransacao;
SELECT COUNT(*) AS total_ItemTransacao FROM ItemTransacao;