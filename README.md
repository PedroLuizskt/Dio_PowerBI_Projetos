README(desafio\_oficina)

\# Projeto de Banco de Dados: Sistema de Gerenciamento para Oficina Mecânica



\## 1. Descrição do Projeto



Este projeto consiste na concepção, criação e implementação de um banco de dados relacional para gerenciar as operações de uma oficina mecânica. O objetivo foi criar um esquema lógico robusto a partir de um cenário de negócio, traduzi-lo em um script SQL funcional e, por fim, demonstrar a capacidade de extrair informações estratégicas através de consultas analíticas.



O banco de dados modela as principais entidades de uma oficina, como clientes, veículos, mecânicos, peças, serviços e, principalmente, as ordens de serviço que conectam todas essas informações.



\## 2. Tecnologias Utilizadas



\* \*\*Linguagem:\*\* SQL (Structured Query Language)

\* \*\*SGBD:\*\* PostgreSQL

\* \*\*Ferramentas:\*\* PgAdmin4 / DBeaver para administração e execução de queries

\* \*\*Versionamento:\*\* Git e GitHub



\## 3. Descrição do Esquema Lógico



O esquema foi projetado de forma normalizada para garantir a integridade e evitar a redundância dos dados. As principais tabelas são:



\### Entidades Principais

\* `clients`: Armazena os dados cadastrais dos clientes proprietários dos veículos.

\* `vehicles`: Contém as informações de cada veículo, com uma chave estrangeira que o relaciona a um cliente (`idClient`).

\* `mechanics`: Mantém o registro dos mecânicos da oficina e suas especialidades.

\* `work\_orders`: É a entidade central transacional. Cada linha representa uma ordem de serviço para um veículo, com data, status e descrição.

\* `parts`: Catálogo de peças disponíveis, com controle de estoque e valor unitário.

\* `services`: Catálogo de serviços oferecidos pela oficina, com seus respectivos valores.



\### Tabelas Associativas (Relações Muitos-para-Muitos)

\* `os\_services`: Tabela de ligação que permite associar múltiplos serviços a uma única ordem de serviço.

\* `os\_parts`: Tabela de ligação que permite associar múltiplas peças (e suas quantidades) a uma única ordem de serviço.

\* `os\_team`: Tabela de ligação que define a equipe de mecânicos que trabalhou em cada ordem de serviço.



\## 4. Perguntas de Negócio Respondidas pelas Queries



O script SQL contém uma série de consultas (DQL) projetadas para responder a perguntas operacionais e estratégicas da oficina, demonstrando o uso de cláusulas como `JOIN`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, expressões, subqueries e `UNION`.



1\.  Listar todas as ordens de serviço que ainda não foram concluídas, mostrando o nome do cliente e o modelo do veículo.

2\.  Calcular o valor total de cada ordem de serviço concluída (soma do valor dos serviços e das peças utilizadas).

3\.  Identificar quais mecânicos trabalharam em mais de uma ordem de serviço.

4\.  Mostrar um relatório detalhado com todos os serviços e peças de uma Ordem de Serviço específica.

5\.  Identificar os 3 clientes que mais gastaram na oficina (Top 3 clientes).

6\.  Verificar quais peças estão com estoque baixo (menos de 50 unidades).

7\.  Descobrir qual é o serviço mais solicitado pela oficina.

8\.  Calcular o tempo médio (em dias) para a conclusão de uma ordem de serviço.



\## 5. Como Utilizar



1\.  Certifique-se de ter o PostgreSQL instalado e um servidor em execução.

2\.  Clone este repositório para a sua máquina local.

3\.  Crie um novo banco de dados no seu servidor PostgreSQL (ex: `oficina\_db`).

4\.  Abra o arquivo `.sql` contido neste repositório em uma ferramenta de sua preferência (PgAdmin4, DBeaver).

5\.  Execute o script completo. Ele criará todas as tabelas, inserirá os dados de teste e disponibilizará as queries de análise na parte final.

