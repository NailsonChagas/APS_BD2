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

-- Start Trigger 2:
-- End Trigger 2:

-- Start Trigger 3:
-- End Trigger 3:

-- Start Trigger 4:
-- End Trigger 4:

-- Start Trigger 5:
-- End Trigger 5:
