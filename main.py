from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker('pt_BR')
Faker.seed(42)
random.seed(42)

NUM_CLIENTES = 100
NUM_FORNECEDORES = 50
NUM_PRODUTOS = 15
NUM_TRANSACOES = 20
TIPOS_TRANSACAO = ['VENDA', 'COMPRA']

clientes = []  # <-- Armazenar os CPFs dos clientes
fornecedores = []  # <-- Armazenar os CNPJs dos fornecedores

print("-- CLIENTES")
# Gerar clientes
for _ in range(NUM_CLIENTES):
    cpf = fake.cpf().replace('.', '').replace('-', '')
    clientes.append(cpf)
    nome = fake.name()
    endereco = fake.address().replace('\n', ', ')
    telefone = fake.phone_number()
    email = fake.email()
    print(f"INSERT INTO Clientes (cpf_cnpj, nome, endereco, telefone, email) VALUES ('{cpf}', '{nome}', '{endereco}', '{telefone}', '{email}');")

print("\n-- FORNECEDORES")
# Gerar fornecedores
for _ in range(NUM_FORNECEDORES):
    cnpj = fake.cnpj().replace('.', '').replace('/', '').replace('-', '')
    fornecedores.append(cnpj)
    nome_empresa = fake.company()
    localizacao = fake.address().replace('\n', ', ')
    contato = fake.name()
    email = fake.email()
    telefone = fake.phone_number()
    print(f"INSERT INTO Fornecedores (cnpj, nome_empresa, localizacao, contato, email, telefone) VALUES ('{cnpj}', '{nome_empresa}', '{localizacao}', '{contato}', '{email}', '{telefone}');")

print("\n-- PRODUTOS")
# Gerar produtos
for i in range(NUM_PRODUTOS):
    id_produto = f"{789100000000 + i}"
    nome = fake.word().capitalize()
    descricao = fake.sentence(nb_words=6)
    preco = round(random.uniform(10, 500), 2)
    print(f"INSERT INTO Produto (id_produto, nome, descricao, preco) VALUES ('{id_produto}', '{nome}', '{descricao}', {preco});")

print("\n-- ESTOQUE")
# Gerar estoque inicial
for i in range(NUM_PRODUTOS):
    id_produto = f"{789100000000 + i}"
    quantidade = random.randint(10, 100)
    print(f"INSERT INTO Estoque (id_produto, quantidade) VALUES ('{id_produto}', {quantidade});")

print("\n-- TRANSACOES E ITENS")

print("\n-- TRANSACOES E ITENS")
id_transacao_atual = 1  # ID manual da transação

for _ in range(NUM_TRANSACOES):
    tipo = random.choice(TIPOS_TRANSACAO)
    
    if tipo == 'VENDA':
        cliente_id = random.choice(clientes)  # Escolher um CPF existente
        fornecedor_id = 'NULL'
    else:
        cliente_id = 'NULL'
        fornecedor_id = random.choice(fornecedores)  # Escolher um CNPJ existente

    data = fake.date_time_between(start_date='-60d', end_date='now')
    forma_pagamento = random.choice(['DINHEIRO', 'CARTÃO', 'PIX', 'BOLETO'])
    observacoes = fake.sentence()

    print(
        f"INSERT INTO Transacao (id_transacao, tipo_transacao, id_cliente, id_fornecedor, data, forma_pagamento, observacoes) "
        f"VALUES ({id_transacao_atual}, '{tipo}', "
        f"{f"'{cliente_id}'" if cliente_id != 'NULL' else 'NULL'}, "
        f"{f"'{fornecedor_id}'" if fornecedor_id != 'NULL' else 'NULL'}, "
        f"'{data}', '{forma_pagamento}', '{observacoes}');"
    )

    # Itens da transação
    qtd_itens = random.randint(1, 4)
    for _ in range(qtd_itens):
        id_produto = f"{789100000000 + random.randint(0, NUM_PRODUTOS - 1)}"
        quantidade = random.randint(1, 5)
        print(
            f"INSERT INTO ItemTransacao (id_transacao, id_produto, quantidade) "
            f"VALUES ({id_transacao_atual}, '{id_produto}', {quantidade});"
        )

    id_transacao_atual += 1

print("\n-- PROMOCOES")

NUM_PROMOCOES = 5  # quantidade de promoções que deseja gerar

for id_promocao in range(1, NUM_PROMOCOES + 1):
    nome_promocao = fake.catch_phrase()
    
    # Gerar data de início e fim válidas
    data_inicio = fake.date_time_between(start_date='-30d', end_date='now')
    data_fim = fake.date_time_between(start_date=data_inicio + timedelta(days=1), end_date=data_inicio + timedelta(days=15))
    
    porcentagem = round(random.uniform(5, 50), 2)  # entre 5% e 50%
    
    # Selecionar de 1 a 4 produtos para aplicar promoção
    qtd_produtos = random.randint(1, 4)
    produtos_ids = [f"{789100000000 + random.randint(0, NUM_PRODUTOS - 1)}" for _ in range(qtd_produtos)]
    produtos_ids = list(set(produtos_ids))  # remover duplicatas
    
    produtos_sql_array = "ARRAY[" + ", ".join(f"'{pid}'" for pid in produtos_ids) + "]"

    print(
        f"INSERT INTO Promocoes (nome_promocao, data_inicio, data_fim, porcentagem, produtos_em_promocao, ativa) "
        f"VALUES ('{nome_promocao}', '{data_inicio}', '{data_fim}', {porcentagem}, {produtos_sql_array}, TRUE);"
    )
