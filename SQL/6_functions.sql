-- Start Function 1: Consulta de disponiblidade de produto
CREATE OR REPLACE FUNCTION consultar_estoque_produto(
    p_id_produto VARCHAR(20)
RETURNS TABLE (
    nome_produto VARCHAR(100),
    quantidade_estoque INT,
    preco_atual DECIMAL(10,2),
    status VARCHAR(10)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.nome,
        e.quantidade,
        p.preco,
        CASE 
            WHEN e.quantidade > 0 AND p.ativo THEN 'DISPONÍVEL'
            WHEN e.quantidade <= 0 AND p.ativo THEN 'ESGOTADO'
            ELSE 'INATIVO'
        END AS status
    FROM 
        Produto p
    JOIN 
        Estoque e ON p.id_produto = e.id_produto
    WHERE 
        p.id_produto = p_id_produto;
END;
$$ LANGUAGE plpgsql;
-- End Function 1: Consulta de disponiblidade de produto

-- Start Function 2: Relatório de vendas por período
CREATE OR REPLACE FUNCTION relatorio_vendas_periodo(
    p_data_inicio TIMESTAMP,
    p_data_fim TIMESTAMP)
RETURNS TABLE (
    data_venda DATE,
    total_vendas DECIMAL(12,2),
    quantidade_itens BIGINT,
    quantidade_transacoes BIGINT)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.data::DATE AS data_venda,
        SUM(t.valor_total) AS total_vendas,
        SUM(it.quantidade) AS quantidade_itens,
        COUNT(DISTINCT t.id_transacao) AS quantidade_transacoes
    FROM 
        Transacao t
    JOIN 
        ItemTransacao it ON t.id_transacao = it.id_transacao
    WHERE 
        t.tipo_transacao = 'VENDA'
        AND t.data BETWEEN p_data_inicio AND p_data_fim
    GROUP BY 
        t.data::DATE
    ORDER BY 
        t.data::DATE;
END;
$$ LANGUAGE plpgsql;
-- End Function 2: Relatório de vendas por período

-- Start Function 3: Promoções ativas por produto
CREATE OR REPLACE FUNCTION consultar_promocoes_ativas_produto(
    p_id_produto VARCHAR(20))
RETURNS TABLE (
    id_promocao INT,
    nome_promocao VARCHAR(100),
    porcentagem_desconto DECIMAL(5,2),
    data_inicio TIMESTAMP,
    data_fim TIMESTAMP)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_promocao,
        p.nome_promocao,
        p.porcentagem,
        p.data_inicio,
        p.data_fim
    FROM 
        Promocoes p
    WHERE 
        p.ativa = TRUE
        AND p.data_inicio <= CURRENT_TIMESTAMP
        AND p.data_fim >= CURRENT_TIMESTAMP
        AND p_id_produto = ANY(p.produtos_em_promocao);
END;
$$ LANGUAGE plpgsql;
-- End Function 3: Promoções ativas por produto