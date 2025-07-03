from faker import Faker
import random
from datetime import timedelta

fake = Faker('pt_BR')
Faker.seed(42)
random.seed(42)

NUM_CLIENTES = 2000
NUM_FORNECEDORES = 500
NUM_PRODUTOS = 15000
NUM_TRANSACOES = 20000
NUM_PROMOCOES = 50
TIPOS_TRANSACAO = ['VENDA', 'COMPRA']

clientes = []
fornecedores = []

print("-- CLIENTES")
for _ in range(NUM_CLIENTES):
    cpf = fake.cpf().replace('.', '').replace('-', '')
    clientes.append(cpf)
    nome = fake.name().replace("'", "''")
    endereco = fake.address().replace('\n', ', ').replace("'", "''")
    telefone = fake.phone_number()
    email = fake.email()
    print(f"INSERT INTO Clientes (cpf_cnpj, nome, endereco, telefone, email) VALUES ('{cpf}', '{nome}', '{endereco}', '{telefone}', '{email}');")

print("\n-- FORNECEDORES")
for _ in range(NUM_FORNECEDORES):
    cnpj = fake.cnpj().replace('.', '').replace('/', '').replace('-', '')
    fornecedores.append(cnpj)
    nome_empresa = fake.company().replace("'", "''")
    localizacao = fake.address().replace('\n', ', ').replace("'", "''")
    contato = fake.name().replace("'", "''")
    email = fake.email()
    telefone = fake.phone_number()
    print(f"INSERT INTO Fornecedores (cnpj, nome_empresa, localizacao, contato, email, telefone) VALUES ('{cnpj}', '{nome_empresa}', '{localizacao}', '{contato}', '{email}', '{telefone}');")

print("\n-- PRODUTOS")
for i in range(NUM_PRODUTOS):
    id_produto = f"{789100000000 + i}"
    nome = fake.word().capitalize()
    descricao = fake.sentence(nb_words=6).replace("'", "''")
    preco = round(random.uniform(10, 500), 2)
    print(f"INSERT INTO Produto (id_produto, nome, descricao, preco) VALUES ('{id_produto}', '{nome}', '{descricao}', {preco});")

# ---------------------------
# Estoque: gerado e mantido
# ---------------------------
estoque_disponivel = {}

print("\n-- ESTOQUE")
for i in range(NUM_PRODUTOS):
    produto_id = f"{789100000000 + i}"
    quantidade = random.randint(10, 100)
    estoque_disponivel[produto_id] = quantidade
    print(f"INSERT INTO Estoque (id_produto, quantidade) VALUES ('{produto_id}', {quantidade});")

# ---------------------------
# PROMOÇÕES
# ---------------------------
print("\n-- PROMOCOES")
for id_promocao in range(1, NUM_PROMOCOES + 1):
    nome_promocao = fake.catch_phrase().replace("'", "''")
    data_inicio = fake.date_time_between(start_date='-30d', end_date='now')
    data_fim = data_inicio + timedelta(days=random.randint(1, 15))
    porcentagem = round(random.uniform(5, 50), 2)
    qtd_produtos = random.randint(1, 4)
    produtos_ids = list(set([f"{789100000000 + random.randint(0, NUM_PRODUTOS - 1)}" for _ in range(qtd_produtos)]))
    produtos_sql_array = "ARRAY[" + ", ".join(f"'{pid}'" for pid in produtos_ids) + "]"
    print(f"INSERT INTO Promocoes (nome_promocao, data_inicio, data_fim, porcentagem, produtos_em_promocao, ativa) VALUES ('{nome_promocao}', '{data_inicio}', '{data_fim}', {porcentagem}, {produtos_sql_array}, TRUE);")

# ---------------------------
# TRANSACOES + ITENS
# ---------------------------
print("\n-- TRANSACOES E ITENS")
id_transacao_atual = 1

for _ in range(NUM_TRANSACOES):
    tipo = random.choice(TIPOS_TRANSACAO)
    if tipo == 'VENDA':
        cliente_id = random.choice(clientes)
        fornecedor_id = 'NULL'
    else:
        cliente_id = 'NULL'
        fornecedor_id = random.choice(fornecedores)

    data = fake.date_time_between(start_date='-60d', end_date='now')
    forma_pagamento = random.choice(['DINHEIRO', 'CARTÃO', 'PIX', 'BOLETO'])
    observacoes = fake.sentence().replace("'", "''")

    cliente_str = f"'{cliente_id}'" if cliente_id != 'NULL' else 'NULL'
    fornecedor_str = f"'{fornecedor_id}'" if fornecedor_id != 'NULL' else 'NULL'

    print(
        f"INSERT INTO Transacao (id_transacao, tipo_transacao, id_cliente, id_fornecedor, forma_pagamento, observacoes) "
        f"VALUES ({id_transacao_atual}, '{tipo}', {cliente_str}, {fornecedor_str}, '{forma_pagamento}', '{observacoes}');"
    )

    qtd_itens = random.randint(1, 4)
    tentativas = 0
    itens_inseridos = 0

    while itens_inseridos < qtd_itens and tentativas < 20:
        id_produto = f"{789100000000 + random.randint(0, NUM_PRODUTOS - 1)}"

        estoque_atual = estoque_disponivel.get(id_produto, 0)

        if tipo == 'VENDA':
            if estoque_atual <= 0:
                tentativas += 1
                continue
            quantidade = random.randint(1, min(5, estoque_atual))
            estoque_disponivel[id_produto] -= quantidade
        else:  # COMPRA sempre aceita, repõe estoque
            quantidade = random.randint(1, 5)
            estoque_disponivel[id_produto] = estoque_atual + quantidade

        usar_promocao = random.choice([True, False])
        if usar_promocao and NUM_PROMOCOES > 0:
            promo_array = random.sample(range(1, NUM_PROMOCOES + 1), random.randint(1, 2))
            promo_sql = "ARRAY[" + ", ".join(str(pid) for pid in promo_array) + "]"
            print(
                f"INSERT INTO ItemTransacao (id_transacao, id_produto, quantidade, id_promocao) "
                f"VALUES ({id_transacao_atual}, '{id_produto}', {quantidade}, {promo_sql});"
            )
        else:
            print(
                f"INSERT INTO ItemTransacao (id_transacao, id_produto, quantidade) "
                f"VALUES ({id_transacao_atual}, '{id_produto}', {quantidade});"
            )

        itens_inseridos += 1

    id_transacao_atual += 1
