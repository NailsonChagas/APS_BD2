-- Aluno: Guilherme Rodrigues dos Santos
-- Aluno: Luiz Eduardo Caldas Kramer
-- Aluno: Matheus Deodato Cadamuro
-- Aluno: Nailson Francisco da Silva Chagas
-- Professor: Ives Venturi Pola

-- registrara todas as alterações feitas nos dados dos clientes
CREATE TABLE AuditoriaClientes (
    id_auditoria SERIAL PRIMARY KEY,
    cpf_cnpj VARCHAR(20) NOT NULL,
    nome_antigo VARCHAR(100),
    nome_novo VARCHAR(100),
    endereco_antigo VARCHAR(200),
    endereco_novo VARCHAR(200),
    telefone_antigo VARCHAR(20),
    telefone_novo VARCHAR(20),
    email_antigo VARCHAR(100),
    email_novo VARCHAR(100),
    data_cadastro_antigo TIMESTAMP,
    data_cadastro_novo TIMESTAMP,
    operacao VARCHAR(10) NOT NULL CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE')),
    usuario VARCHAR(100) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cpf_cnpj) REFERENCES Clientes(cpf_cnpj)
);

-- INSERT
CREATE OR REPLACE FUNCTION audit_clientes_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO AuditoriaClientes (
        cpf_cnpj,
        nome_novo,
        endereco_novo,
        telefone_novo,
        email_novo,
        data_cadastro_novo,
        operacao,
        usuario,
        data_hora
    ) VALUES (
        NEW.cpf_cnpj,
        NEW.nome,
        NEW.endereco,
        NEW.telefone,
        NEW.email,
        NEW.data_cadastro,
        'INSERT',
        current_user,
        NOW()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_clientes_insert
AFTER INSERT ON Clientes
FOR EACH ROW
EXECUTE FUNCTION audit_clientes_insert();

-- UPDATE
CREATE OR REPLACE FUNCTION audit_clientes_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO AuditoriaClientes (
        cpf_cnpj,
        nome_antigo, nome_novo,
        endereco_antigo, endereco_novo,
        telefone_antigo, telefone_novo,
        email_antigo, email_novo,
        data_cadastro_antigo, data_cadastro_novo,
        operacao,
        usuario,
        data_hora
    ) VALUES (
        NEW.cpf_cnpj,
        OLD.nome, NEW.nome,
        OLD.endereco, NEW.endereco,
        OLD.telefone, NEW.telefone,
        OLD.email, NEW.email,
        OLD.data_cadastro, NEW.data_cadastro,
        'UPDATE',
        current_user,
        NOW()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_clientes_update
AFTER UPDATE ON Clientes
FOR EACH ROW
EXECUTE FUNCTION audit_clientes_update();

-- DELETE
CREATE OR REPLACE FUNCTION audit_clientes_delete()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO AuditoriaClientes (
        cpf_cnpj,
        nome_antigo,
        endereco_antigo,
        telefone_antigo,
        email_antigo,
        data_cadastro_antigo,
        operacao,
        usuario,
        data_hora
    ) VALUES (
        OLD.cpf_cnpj,
        OLD.nome,
        OLD.endereco,
        OLD.telefone,
        OLD.email,
        OLD.data_cadastro,
        'DELETE',
        current_user,
        NOW()
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_clientes_delete
AFTER DELETE ON Clientes
FOR EACH ROW
EXECUTE FUNCTION audit_clientes_delete();