-- Start View 1: transações de venda, agrupadas por cliente e período de tempo, permitindo análises de desempenho de vendas e comportamento do cliente
CREATE OR REPLACE VIEW view_vendas_por_periodo_cliente AS
SELECT 
    t.id_transacao,
    c.nome AS cliente,
    t.data,
    EXTRACT(MONTH FROM t.data) AS mes,
    EXTRACT(YEAR FROM t.data) AS ano,
    COUNT(it.id_item_transacao) AS qtd_itens,
    SUM(it.quantidade) AS qtd_total_produtos,
    t.valor_total,
    t.forma_pagamento
FROM 
    Transacao t
JOIN 
    Clientes c ON t.id_cliente = c.cpf_cnpj
JOIN 
    ItemTransacao it ON t.id_transacao = it.id_transacao
WHERE 
    t.tipo_transacao = 'VENDA'
GROUP BY 
    t.id_transacao, c.nome, t.data, t.valor_total, t.forma_pagamento
ORDER BY 
    t.data DESC;
-- End View 1: transações de venda, agrupadas por cliente e período de tempo, permitindo análises de desempenho de vendas e comportamento do cliente

-- Start View 2: desempenho em vendas
CREATE OR REPLACE VIEW view_produtos_mais_vendidos AS
SELECT 
    p.id_produto,
    p.nome,
    p.descricao,
    p.preco AS preco_base,
    SUM(CASE WHEN t.tipo_transacao = 'VENDA' THEN it.quantidade ELSE 0 END) AS qtd_vendida,
    SUM(CASE WHEN t.tipo_transacao = 'COMPRA' THEN it.quantidade ELSE 0 END) AS qtd_comprada,
    e.quantidade AS estoque_atual,
    e.ultima_atualizacao AS ultima_movimentacao,
    (SUM(CASE WHEN t.tipo_transacao = 'VENDA' THEN it.preco_total ELSE 0 END)) AS total_vendido,
    (SUM(CASE WHEN t.tipo_transacao = 'VENDA' THEN it.quantidade ELSE 0 END) * p.preco - 
     SUM(CASE WHEN t.tipo_transacao = 'VENDA' THEN it.preco_total ELSE 0 END)) AS desconto_total_aplicado
FROM 
    Produto p
LEFT JOIN 
    ItemTransacao it ON p.id_produto = it.id_produto
LEFT JOIN 
    Transacao t ON it.id_transacao = t.id_transacao
LEFT JOIN 
    Estoque e ON p.id_produto = e.id_produto
GROUP BY 
    p.id_produto, p.nome, p.descricao, p.preco, e.quantidade, e.ultima_atualizacao
ORDER BY 
    qtd_vendida DESC;
-- End View 2: desempenho em vendas

-- Start View 3: permite analisar a eficácia das campanhas promocionais
CREATE OR REPLACE VIEW view_desempenho_promocoes AS
SELECT 
    pr.id_promocao,
    pr.nome_promocao,
    pr.data_inicio,
    pr.data_fim,
    pr.porcentagem,
    COUNT(DISTINCT t.id_transacao) AS qtd_transacoes,
    COUNT(it.id_item_transacao) AS qtd_itens_vendidos,
    SUM(it.preco_total) AS total_vendido,
    SUM((SELECT p.preco FROM Produto p WHERE p.id_produto = it.id_produto) * it.quantidade) - SUM(it.preco_total) AS total_desconto,
    array_length(pr.produtos_em_promocao, 1) AS qtd_produtos_promocao,
    STRING_AGG(DISTINCT p.nome, ', ') AS produtos_promocao
FROM 
    Promocoes pr
LEFT JOIN 
    ItemTransacao it ON pr.id_promocao = ANY(it.id_promocao)
LEFT JOIN 
    Transacao t ON it.id_transacao = t.id_transacao
LEFT JOIN 
    Produto p ON p.id_produto = ANY(pr.produtos_em_promocao)
WHERE 
    pr.ativa = TRUE
GROUP BY 
    pr.id_promocao, pr.nome_promocao, pr.data_inicio, pr.data_fim, pr.porcentagem, pr.produtos_em_promocao
ORDER BY 
    pr.data_inicio DESC;
-- End View 3: permite analisar a eficácia das campanhas promocionais

SELECT * FROM Clientes;

SELECT * FROM Estoque;

SELECT * FROM Produto;

SELECT * FROM Transacao;

SELECT * FROM ItemTransacao;

SELECT * FROM Promocoes;

SELECT * FROM Fornecedores;
