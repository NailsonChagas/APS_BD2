from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker('pt_BR')
Faker.seed(42)
random.seed(42)

NUM_CLIENTES = 10
NUM_FORNECEDORES = 5
NUM_PRODUTOS = 15
NUM_TRANSACOES = 20
TIPOS_TRANSACAO = ['VENDA', 'COMPRA']

# Gerar clientes
for _ in range(NUM_CLIENTES):
    cpf = fake.cpf().replace('.', '').replace('-', '')
    nome = fake.name()
    endereco = fake.address().replace('\n', ', ')
    telefone = fake.phone_number()
    email = fake.email()
    print(f"INSERT INTO Clientes (cpf_cnpj, nome, endereco, telefone, email) VALUES ('{cpf}', '{nome}', '{endereco}', '{telefone}', '{email}');")

print("\n-- FORNECEDORES")
# Gerar fornecedores
for _ in range(NUM_FORNECEDORES):
    cnpj = fake.cnpj().replace('.', '').replace('/', '').replace('-', '')
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
# Simular transações e itens
for i in range(NUM_TRANSACOES):
    tipo = random.choice(TIPOS_TRANSACAO)
    if tipo == 'VENDA':
        cliente_id = fake.cpf().replace('.', '').replace('-', '')
        fornecedor_id = 'NULL'
    else:
        cliente_id = 'NULL'
        fornecedor_id = fake.cnpj().replace('.', '').replace('/', '').replace('-', '')

    valor_total = 0
    data = fake.date_time_between(start_date='-60d', end_date='now')
    forma_pagamento = random.choice(['DINHEIRO', 'CARTÃO', 'PIX', 'BOLETO'])
    observacoes = fake.sentence()
    
    print(f"INSERT INTO Transacao (tipo_transacao, id_cliente, id_fornecedor, data, forma_pagamento, observacoes) VALUES ('{tipo}', {f"'{cliente_id}'" if cliente_id != 'NULL' else 'NULL'}, {f"'{fornecedor_id}'" if fornecedor_id != 'NULL' else 'NULL'}, '{data}', '{forma_pagamento}', '{observacoes}');")

    # Simular itens da transação
    qtd_itens = random.randint(1, 4)
    for _ in range(qtd_itens):
        id_produto = f"{789100000000 + random.randint(0, NUM_PRODUTOS - 1)}"
        quantidade = random.randint(1, 5)
        print(f"-- Suponha que o último id_transacao foi {i+1}")
        print(f"INSERT INTO ItemTransacao (id_transacao, id_produto, quantidade) VALUES ({i+1}, '{id_produto}', {quantidade});")
