-- Start Trigger 1: atualizar estoque com base em inserção em ItemTransacao
CREATE OR REPLACE FUNCTION atualizar_estoque()
RETURNS TRIGGER AS $$
DECLARE
    tipo_trans VARCHAR(10);
    estoque_atual INT;
    produto_existe BOOLEAN;
BEGIN
    SELECT quantidade INTO estoque_atual
    FROM Estoque
    WHERE id_produto = NEW.id_produto;

    produto_existe := FOUND;
    
    SELECT tipo_transacao INTO tipo_trans
    FROM Transacao
    WHERE id_transacao = NEW.id_transacao;
    
    IF NOT produto_existe THEN
        RAISE EXCEPTION 'Produto % não encontrado no estoque', NEW.id_produto;
    END IF;
    
    IF tipo_trans = 'COMPRA' THEN
        UPDATE Estoque
        SET quantidade = quantidade + NEW.quantidade,
            ultima_atualizacao = CURRENT_TIMESTAMP
        WHERE id_produto = NEW.id_produto;

    ELSIF tipo_trans = 'VENDA' THEN
        IF estoque_atual < NEW.quantidade THEN
            RAISE EXCEPTION 'Estoque insuficiente para o produto %. Estoque atual: %, Quantidade solicitada: %', 
                            NEW.id_produto, estoque_atual, NEW.quantidade;
        END IF;
        
        UPDATE Estoque
        SET quantidade = quantidade - NEW.quantidade,
            ultima_atualizacao = CURRENT_TIMESTAMP
        WHERE id_produto = NEW.id_produto;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_atualizar_estoque
AFTER INSERT ON ItemTransacao
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque();
-- End Trigger 1: atualizar estoque com base em inserção em ItemTransacao

-- Start Trigger 2: calcular o preço unitário e total do ItemTransacao com base nos descontos existentes
CREATE OR REPLACE FUNCTION calcular_preco()
RETURNS TRIGGER AS $$
DECLARE
    preco_base DECIMAL(10,2);
    desconto_total DECIMAL(5,2) := 0;
    preco_final DECIMAL(10,2);
    promocao_record RECORD;
    promocao_id INT;
BEGIN
    SELECT preco INTO preco_base FROM Produto WHERE id_produto = NEW.id_produto;
    
    IF preco_base IS NULL THEN
        RAISE EXCEPTION 'Produto com ID % não encontrado', NEW.id_produto;
    END IF;
    
    preco_final := preco_base;
    
    IF NEW.id_promocao IS NOT NULL AND array_length(NEW.id_promocao, 1) > 0 THEN
        FOREACH promocao_id IN ARRAY NEW.id_promocao LOOP
            SELECT * INTO promocao_record 
            FROM Promocoes 
            WHERE id_promocao = promocao_id 
              AND ativa = TRUE
              AND CURRENT_TIMESTAMP BETWEEN data_inicio AND data_fim
              AND NEW.id_produto = ANY(produtos_em_promocao);
            
            IF FOUND THEN
                preco_final := preco_final * (1 - (promocao_record.porcentagem / 100));
            END IF;
        END LOOP;
    END IF;
    
    -- se for negativo vou colocar como 1 centavo
    IF preco_final <= 0 THEN
        preco_final := 0.1;
    END IF;
    
    NEW.preco_unitario := preco_final;
    NEW.preco_total := NEW.preco_unitario * NEW.quantidade;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_calcular_preco_com_promocoes
BEFORE INSERT ON ItemTransacao
FOR EACH ROW
EXECUTE FUNCTION calcular_preco();
-- End Trigger 2: calcular o preço unitário e total do ItemTransacao com base nos descontos existentes

-- Start Trigger 3: calculcar o valor total da transação baseado em seus ItemTransacao
CREATE OR REPLACE FUNCTION atualizar_total_transacao()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Transacao
    SET valor_total = valor_total + NEW.preco_total
    WHERE id_transacao = NEW.id_transacao;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_atualizar_total_transacao
AFTER INSERT ON ItemTransacao
FOR EACH ROW
EXECUTE FUNCTION atualizar_total_transacao();
-- End Trigger 3: calculcar o valor total da transação baseado em seus ItemTransacao