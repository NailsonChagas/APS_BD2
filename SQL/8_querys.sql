
-- 1) CLIENTES — busca por nome
-- Usa: idx_clientes_nome

EXPLAIN ANALYZE
SELECT *
FROM Clientes
WHERE nome LIKE 'Guilherme Rodrigues';

-- 2) CLIENTES — busca por email
-- Usa: idx_clientes_email

EXPLAIN ANALYZE
SELECT *
FROM Clientes
WHERE email = 'maria46@example.net';

-- 3) FORNECEDORES — busca por nome_empresa
-- Usa: idx_fornecedores_nome_empresa

EXPLAIN ANALYZE
SELECT *
FROM Fornecedores
WHERE nome_empresa LIKE 'Guerra S/A';

-- 4) PRODUTO — busca por nome
-- Usa: idx_produto_nome

EXPLAIN ANALYZE
SELECT *
FROM Produto
WHERE nome LIKE 'Tempora';

-- 5) ESTOQUE — consulta por produto
-- Usa: idx_estoque_id_produto

EXPLAIN ANALYZE
SELECT *
FROM Estoque
WHERE id_produto = '789100000001';

-- 6) PROMOÇÕES — filtro por período
-- Usa: idx_promocoes_data

EXPLAIN ANALYZE
SELECT *
FROM Promocoes
WHERE ativa = TRUE
  AND data_inicio <= NOW()
  AND data_fim >= NOW();
  
-- 7) PROMOÇÕES — verificar produtos de uma promoção
-- Usa: idx_promocoes_produtos_em_promocao (GIN index)

EXPLAIN ANALYZE
SELECT *
FROM Promocoes
WHERE ativa = TRUE
AND produtos_em_promocao @> ARRAY['789100000001']::varchar[];

-- 8) TRANSACAO — todas transações de um cliente
-- Usa: idx_transacao_id_cliente

EXPLAIN ANALYZE
SELECT *
FROM Transacao
WHERE id_cliente = '74930285160';

-- 9) TRANSACAO — todas compras de um fornecedor
-- Usa: idx_transacao_id_fornecedor

EXPLAIN ANALYZE
SELECT *
FROM Transacao
WHERE id_fornecedor = '89067423000132';

-- 10) TRANSACAO — filtro por data
-- Usa: idx_transacao_data

EXPLAIN ANALYZE
SELECT *
FROM Transacao
WHERE data >= '2025-07-01'
  AND data < '2025-08-01'
ORDER BY data;

-- 11) TRANSACAO — todas VENDAS de um fornecedor em período
-- Usa: idx_transacao_fornecedor_tipo_data

EXPLAIN ANALYZE
SELECT *
FROM Transacao
WHERE id_fornecedor = '89067423000132'
AND tipo_transacao = 'COMPRA'
AND data BETWEEN '2025-01-01' AND '2025-08-30';

-- 12) ITEMTRANSACAO — itens de uma transação
-- Usa: idx_itemtransacao_id_transacao

EXPLAIN ANALYZE
SELECT *
FROM ItemTransacao
WHERE id_transacao = 1000;

-- 12) ITEMTRANSACAO — consulta por produto
-- Usa: idx_itemtransacao_id_produto

EXPLAIN ANALYZE
SELECT *
FROM ItemTransacao
WHERE id_produto = '789100000001';

-- 13) ITEMTRANSACAO — consulta por cliente, tipo, data
-- idx_transacao_cliente_tipo_data

EXPLAIN ANALYZE
SELECT *
FROM Transacao
WHERE id_cliente = '74930285160'
  AND tipo_transacao = 'VENDA'
  AND data BETWEEN '2025-01-01' AND '2025-08-30';

-- 14) ITEMTRANSACAO — busca por produto com filtro por quantidade
-- Usa: idx_itemtransacao_produto_quantidade

EXPLAIN ANALYZE
SELECT *
FROM ItemTransacao
WHERE id_produto = '789100000001'
AND quantidade > 3;


SELECT * FROM consultar_estoque_produto('789100000001');
SELECT * FROM relatorio_vendas_periodo('2025-01-01', '2025-09-03');
SELECT * FROM consultar_promocoes_ativas_produto('789100001375');

SELECT * FROM view_vendas_por_periodo_cliente;
SELECT * FROM view_produtos_mais_vendidos;
SELECT * FROM view_desempenho_promocoes;

SELECT * FROM AuditoriaClientes;