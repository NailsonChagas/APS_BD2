-- View para listar os itens em promoção
CREATE VIEW view_itens_em_promocao AS
SELECT
    p.id_produto,
    p.nome AS nome_produto,
    pr.id_promocao,
    pr.nome_promocao,
    pr.porcentagem,
    pr.data_inicio,
    pr.data_fim
FROM
    Produto p
JOIN
    Promocoes pr ON p.id_produto = ANY(pr.produtos_em_promocao)
WHERE
    pr.ativa = TRUE
    AND CURRENT_TIMESTAMP BETWEEN pr.data_inicio AND pr.data_fim;

-- View para listar transações detalhadas
CREATE VIEW view_estoque_detalhado AS
SELECT
    p.id_produto,
    p.nome AS nome_produto,
    p.preco,
    p.ativo AS produto_ativo,
    e.quantidade,
    e.ultima_atualizacao
FROM
    Produto p
JOIN
    Estoque e ON p.id_produto = e.id_produto;

-- View para listar transações de venda e compra
CREATE VIEW view_vendas_clientes AS
SELECT
    c.cpf_cnpj,
    c.nome AS nome_cliente,
    COUNT(t.id_transacao) AS total_vendas,
    SUM(t.valor_total) AS valor_total_vendas
FROM
    Clientes c
JOIN
    Transacao t ON c.cpf_cnpj = t.id_cliente
WHERE
    t.tipo_transacao = 'VENDA'
GROUP BY
    c.cpf_cnpj, c.nome;
