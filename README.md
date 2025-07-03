# APS de Banco de Dados 2

## Objetivo
Defina uma aplicação que envolva modelar um sistema para projetar um banco de dados. Documente cada etapa em formato de relatório técnico para entrega na data especificada.

## Como executar
- `populate_tables.sql` é criado pelo arquivo `popular.py`
- Ordem de execução dos arquivos SQL:
   1. `1_create_tables.sql`
   2. `2_triggers.sql`
   3. `3_audit.sql`
   4. `4_populate_tables.sql`
   5. `5_views.sql`
   6. `6_functions.sql`

## Itens Avaliados

1. **Escolha da Aplicação -> (Feito)**  
   - Selecione uma aplicação com dados correlacionados e descreva seu contexto.

   A aplicação escolhida por nós é um sistema de banco de dados de um mercado, com gestão de clientes, fornecedores, produtos, estoque, promoções e transações comerciais.

   A base do sistema são os produtos, que possuem um registro único no estoque com sua quantidade disponível. Cada produto pode participar de múltiplas promoções ativas, desde que esteja ativo no cadastro. Quando um produto é desativado, o sistema automaticamente o remove de todas as promoções em que está incluído.

   As transações comerciais são o núcleo das operações e se dividem em dois tipos: vendas para clientes e compras de fornecedores. O sistema terá regras para garantir que cada transação tenha apenas um destinatário (cliente ou fornecedor), conforme seu tipo. Cada transação pode conter múltiplos itens, cujos preços são calculados considerando possíveis promoções aplicáveis no momento da operação.

   O controle de estoque é automatizado, com o sistema verificando a disponibilidade antes de registrar uma venda, impedindo transações que ultrapassem a quantidade em estoque. Nas compras, o estoque é automaticamente incrementado. Todas as movimentações serão registradas com timestamp para auditoria.

   As promoções devem ser flexíveis, podendo uma mesma promoção ser aplicada a diversos produtos. O sistema deve permitir que múltiplos descontos sejam aplicados cumulativamente sobre um mesmo produto, desde que dentro do período de vigência. O sistema garante que os preços finais nunca sejam zerados, atribuindo um valor mínimo simbólico de 0,01 caso o valor com descontos seja inferior a isso.

2. **Diagrama Entidade-Relacionamento (DER) -> (Feito)**  
   - Elabore um diagrama ER representando a aplicação escolhida.

3. **Mapeamento para Modelo Relacional -> (Feito)**  
   - Converta o DER para o modelo relacional, indicando as restrições de integridade (chaves primárias, estrangeiras, etc.).

4. **Script SQL (PostgreSQL) -> (Feito)**  
   - Gere o script de criação das tabelas no PostgreSQL, incluindo todas as restrições necessárias.

5. **População das Tabelas**  
   - Insira dados nas tabelas (preferencialmente reais, se possível), suficientes para realizar consultas.

6. **Índices**  
   - Crie índices adequados para otimizar consultas.  
   - Indique quais consultas foram beneficiadas e mostre o resultado do `EXPLAIN`.

7. **Funções**  
   - Crie 3 funções que representem consultas comuns ou realizem tarefas específicas nas tabelas.

8. **Visões e Auditoria**  
   - Crie 3 visões (views) comuns.  
   - Implemente uma tabela de auditoria para uma das tabelas principais.

9. **Triggers -> (Feito)**  
   - Crie 3 triggers para tratar eventos em tabelas com atributos derivados e auditorias.  

## Entrega  
O relatório técnico deve ser entregue na data especificada, contendo todas as etapas detalhadas.