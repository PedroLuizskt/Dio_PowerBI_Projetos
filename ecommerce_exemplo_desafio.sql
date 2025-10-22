-- Database: ecommerce_ex

-- DROP DATABASE IF EXISTS ecommerce_ex;
-- Autor = Pedro Luiz
CREATE DATABASE ecommerce_ex
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Portuguese_Brazil.1252'
    LC_CTYPE = 'Portuguese_Brazil.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
-- =====================================================================
-- SCRIPT SQL FINAL - DESAFIO DE PROJETO ECOMMERCE (POSTGRESQL)
-- =====================================================================

-- -----------------------------------------------------
-- PARTE 1: DDL (Data Definition Language)
-- -----------------------------------------------------

CREATE TYPE client_type_enum AS ENUM ('PF', 'PJ');
CREATE TYPE product_category_enum AS ENUM ('Eletrônico', 'Vestimenta', 'Brinquedos', 'Alimentos', 'Móveis');
CREATE TYPE payment_type_enum AS ENUM ('Boleto', 'Cartão', 'Dois cartões');
CREATE TYPE order_status_enum AS ENUM ('Cancelado', 'Confirmado', 'Em processamento');
CREATE TYPE product_order_status_enum AS ENUM ('Disponível', 'Sem estoque');
CREATE TYPE delivery_status_enum AS ENUM ('Aguardando Envio', 'Em Trânsito', 'Entregue', 'Cancelado');

CREATE TABLE clients (
    idClient SERIAL PRIMARY KEY,
    Fname VARCHAR(20) NOT NULL,
    Minit CHAR(3),
    Lname VARCHAR(20),
    client_type client_type_enum NOT NULL,
    CPF CHAR(11),
    CNPJ CHAR(14),
    Address VARCHAR(255),
    CONSTRAINT unique_cpf_client UNIQUE (CPF),
    CONSTRAINT unique_cnpj_client UNIQUE (CNPJ),
    CONSTRAINT chk_client_type CHECK (
        (client_type = 'PF' AND CPF IS NOT NULL AND CNPJ IS NULL) OR
        (client_type = 'PJ' AND CNPJ IS NOT NULL AND CPF IS NULL)
    )
);

CREATE TABLE product (
    idProduct SERIAL PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    classification_kids BOOLEAN DEFAULT FALSE,
    category product_category_enum NOT NULL,
    avaliacao FLOAT DEFAULT 0,
    size VARCHAR(10)
);

CREATE TABLE payments (
    idPayment SERIAL PRIMARY KEY,
    idClient INT NOT NULL,
    typePayment payment_type_enum NOT NULL,
    cardNumber VARCHAR(16),
    cardHolderName VARCHAR(50),
    expirationDate CHAR(5),
    CONSTRAINT fk_payments_client FOREIGN KEY (idClient) REFERENCES clients(idClient)
);

CREATE TABLE orders (
    idOrder SERIAL PRIMARY KEY,
    idOrderClient INT,
    idOrderPayment INT,
    orderStatus order_status_enum DEFAULT 'Em processamento',
    orderDescription VARCHAR(255),
    sendValue FLOAT DEFAULT 10,
    paymentCash BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_orders_client FOREIGN KEY (idOrderClient) REFERENCES clients(idClient) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_orders_payment FOREIGN KEY (idOrderPayment) REFERENCES payments(idPayment)
);

CREATE TABLE delivery (
    idDelivery SERIAL PRIMARY KEY,
    idOrder INT NOT NULL,
    deliveryStatus delivery_status_enum DEFAULT 'Aguardando Envio',
    trackingCode VARCHAR(20),
    CONSTRAINT fk_delivery_order FOREIGN KEY (idOrder) REFERENCES orders(idOrder)
);

CREATE TABLE productStorage (
    idProdStorage SERIAL PRIMARY KEY,
    storageLocation VARCHAR(255),
    quantity INT DEFAULT 0
);

CREATE TABLE supplier (
    idSupplier SERIAL PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    CNPJ CHAR(14) NOT NULL,
    contact CHAR(11) NOT NULL,
    CONSTRAINT unique_supplier UNIQUE (CNPJ)
);

CREATE TABLE seller (
    idSeller SERIAL PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    AbstName VARCHAR(255),
    CNPJ CHAR(14),
    CPF CHAR(11),
    location VARCHAR(255),
    contact CHAR(11) NOT NULL,
    CONSTRAINT unique_cnpj_seller UNIQUE (CNPJ),
    CONSTRAINT unique_cpf_seller UNIQUE (CPF)
);

CREATE TABLE productSeller (
    idPseller INT,
    idProduct INT,
    prodQuantity INT DEFAULT 1,
    PRIMARY KEY (idPseller, idProduct),
    CONSTRAINT fk_product_seller FOREIGN KEY (idPseller) REFERENCES seller(idSeller),
    CONSTRAINT fk_product_product_ps FOREIGN KEY (idProduct) REFERENCES product(idProduct)
);

CREATE TABLE productOrder (
    idPOproduct INT,
    idPOorder INT,
    poQuantity INT DEFAULT 1,
    poStatus product_order_status_enum DEFAULT 'Disponível',
    PRIMARY KEY (idPOproduct, idPOorder),
    CONSTRAINT fk_productorder_product FOREIGN KEY (idPOproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_productorder_order FOREIGN KEY (idPOorder) REFERENCES orders(idOrder)
);

CREATE TABLE storageLocation (
    idLproduct INT,
    idLstorage INT,
    location VARCHAR(255) NOT NULL,
    PRIMARY KEY (idLproduct, idLstorage),
    CONSTRAINT fk_storage_location_product FOREIGN KEY (idLproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_storage_location_storage FOREIGN KEY (idLstorage) REFERENCES productStorage(idProdStorage)
);

CREATE TABLE productSupplier (
    idPsSupplier INT,
    idPsProduct INT,
    quantity INT NOT NULL,
    PRIMARY KEY (idPsSupplier, idPsProduct),
    CONSTRAINT fk_product_supplier_supplier FOREIGN KEY (idPsSupplier) REFERENCES supplier(idSupplier),
    CONSTRAINT fk_product_supplier_product FOREIGN KEY (idPsProduct) REFERENCES product(idProduct)
);

-- -----------------------------------------------------
-- PARTE 2: DML (Data Manipulation Language) - 
-- -----------------------------------------------------

INSERT INTO clients (Fname, Minit, Lname, client_type, CPF, Address) VALUES
('Maria', 'M', 'Silva', 'PF', '12345678901', 'Rua Silva de Prata 29, Carangola - Cidade das Flores'),
('Matheus', 'O', 'Pimentel', 'PF', '98765432109', 'Rua Almeida 289, Centro - Cidade das Flores'),
('Ricardo', 'F', 'Silva', 'PF', '45678912304', 'Avenida Almeida Vinha 1009, Centro - Cidade das Flores'),
('Julia', 'S', 'França', 'PF', '78912345605', 'Rua Laranjeiras 861, Centro - Cidade das Flores');

INSERT INTO clients (Fname, Lname, client_type, CNPJ, Address) VALUES
('Tech', 'Solutions', 'PJ', '89765432109876', 'Rua das Indústrias 500, Distrito Industrial - Varginha'),
('Kids', 'World', 'PJ', '56789123405678', 'Avenida do Comércio 1500, Centro - Pouso Alegre');

-- CORREÇÃO APLICADA AQUI: 'avaliação' foi trocado para 'avaliacao'
INSERT INTO product (Pname, classification_kids, category, avaliacao, size) VALUES
('Fone de ouvido', FALSE, 'Eletrônico', '4', NULL),
('Barbie Elsa', TRUE, 'Brinquedos', '3', NULL),
('Body Carters', TRUE, 'Vestimenta', '5', NULL),
('Microfone Vedo', FALSE, 'Eletrônico', '4', NULL),
('Sofá retrátil', FALSE, 'Móveis', '3', '3x57x80'),
('Farinha de arroz', FALSE, 'Alimentos', '2', NULL),
('Monitor', FALSE, 'Eletrônico', '5', '32"');

INSERT INTO payments (idClient, typePayment, cardNumber, cardHolderName, expirationDate) VALUES
(1, 'Cartão', '1234567890123456', 'MARIA M SILVA', '12/28'),
(2, 'Cartão', '9876543210987654', 'MATHEUS O PIMENTEL', '10/27'),
(3, 'Boleto', NULL, NULL, NULL),
(4, 'Dois cartões', '1111222233334444', 'JULIA S FRANÇA', '03/29'),
(5, 'Boleto', NULL, NULL, NULL);

INSERT INTO orders (idOrderClient, idOrderPayment, orderStatus, orderDescription, sendValue) VALUES
(1, 1, 'Confirmado', 'compra via aplicativo', 15.50),
(2, 2, 'Confirmado', 'compra via aplicativo', 50),
(3, 3, 'Em processamento', 'compra via web site', 150),
(1, 1, 'Confirmado', 'compra via web site', 15.50),
(4, 4, 'Cancelado', 'compra via aplicativo', 25.00),
(5, 5, 'Confirmado', 'compra de fornecedor', 250.00);

INSERT INTO delivery (idOrder, deliveryStatus, trackingCode) VALUES
(1, 'Em Trânsito', 'BR123456789PY'),
(2, 'Entregue', 'BR987654321BR'),
(3, 'Aguardando Envio', NULL),
(4, 'Entregue', 'BR555666777SP'),
(5, 'Cancelado', NULL),
(6, 'Em Trânsito', 'BR444333222MG');

INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus) VALUES
(1, 1, 2, 'Disponível'),
(2, 1, 1, 'Disponível'),
(3, 2, 1, 'Sem estoque'),
(4, 3, 1, 'Disponível'),
(7, 4, 1, 'Disponível'),
(1, 5, 1, 'Disponível'),
(6, 6, 100, 'Disponível');

INSERT INTO supplier (SocialName, CNPJ, contact) VALUES
('Almeida e Filhos', '12345678912345', '21985474'),
('Eletrônicos Silva', '85451964914345', '21985484'),
('Eletrônicos Valma', '93456789393469', '21975474');

INSERT INTO productSupplier (idPsSupplier, idPsProduct, quantity) VALUES
(1, 1, 500),
(1, 2, 400),
(2, 4, 630),
(3, 3, 5),
(2, 5, 10);

INSERT INTO seller (SocialName, AbstName, CNPJ, CPF, location, contact) VALUES
('Tech eletronics', NULL, '12345678945632', NULL, 'Rio de Janeiro', '219946287'),
('Botique Durgas', NULL, NULL, '987456312', 'Rio de Janeiro', '219547895'),
('Kids World', NULL, '45678912365448', NULL, 'São Paulo', '1198657484');

INSERT INTO seller (SocialName, CNPJ, location, contact) VALUES
('Almeida e Filhos', '12345678912345', 'Niterói', '21985474');

INSERT INTO productSeller (idPseller, idProduct, prodQuantity) VALUES
(1, 6, 80),
(2, 7, 10);

INSERT INTO productStorage (storageLocation, quantity) VALUES
('Rio de Janeiro', 1000),
('São Paulo', 5000),
('São Paulo', 2000),
('Brasília', 600);

INSERT INTO storageLocation (idLproduct, idLstorage, location) VALUES
(1, 2, 'SP'),
(2, 3, 'SP');
-- --------------------------------------------------------------------
-- PARTE 3: DQL (Data Query Language) - Respostas do Desafio
-- --------------------------------------------------------------------

-- Pergunta 1: Quantos pedidos foram feitos por cada cliente?
SELECT 
    c.idClient, 
    CONCAT(c.Fname, ' ', c.Lname) AS Client_Name,
    c.client_type,
    COUNT(o.idOrder) AS Number_of_Orders
FROM 
    clients AS c
LEFT JOIN
    orders AS o ON c.idClient = o.idOrderClient
GROUP BY 
    c.idClient, Client_Name, c.client_type
ORDER BY 
    Number_of_Orders DESC;

-- Pergunta 2: Algum vendedor também é fornecedor?
SELECT 
    s.SocialName AS Seller_Name,
    s.CNPJ,
    sp.SocialName AS Supplier_Name
FROM 
    seller AS s
INNER JOIN
    supplier AS sp ON s.CNPJ = sp.CNPJ;

-- Pergunta 3: Relação de produtos, fornecedores e estoques.
SELECT 
    p.Pname AS Product_Name,
    p.category,
    s.SocialName AS Supplier_Name,
    ps.quantity AS Supplier_Stock,
    st.storageLocation,
    st.quantity AS Storage_Stock
FROM 
    product AS p
LEFT JOIN 
    productSupplier AS ps ON p.idProduct = ps.idPsProduct
LEFT JOIN 
    supplier AS s ON ps.idPsSupplier = s.idSupplier
LEFT JOIN 
    storageLocation AS sl ON p.idProduct = sl.idLproduct
LEFT JOIN 
    productStorage AS st ON sl.idLstorage = st.idProdStorage
ORDER BY 
    p.Pname;

-- Pergunta 4: Relação de nomes dos fornecedores e nomes dos produtos.
SELECT
    s.SocialName AS Supplier_Name,
    p.Pname AS Product_Name
FROM
    supplier AS s
INNER JOIN
    productSupplier AS ps ON s.idSupplier = ps.idPsSupplier
INNER JOIN
    product AS p ON ps.idPsProduct = p.idProduct
ORDER BY
    Supplier_Name, Product_Name;

-- Pergunta 5 (Complexa): Qual a categoria de produto mais vendida e qual o faturamento por categoria?
SELECT
    p.category,
    COUNT(po.idPOproduct) AS Total_Items_Sold,
    ROUND(CAST(SUM(po.poQuantity * p.avaliacao * 10) AS NUMERIC), 2) AS Estimated_Revenue
FROM 
    productOrder AS po
JOIN 
    product AS p ON po.idPOproduct = p.idProduct
GROUP BY
    p.category
ORDER BY
    Total_Items_Sold DESC;

-- Pergunta 6 (Complexa): Categorizar clientes por número de pedidos e ver o status do último pedido de cada um.
WITH LastOrderStatus AS (
    SELECT 
        idOrderClient,
        orderStatus,
        ROW_NUMBER() OVER(PARTITION BY idOrderClient ORDER BY idOrder DESC) as rn
    FROM orders
)
SELECT
    CONCAT(c.Fname, ' ', c.Lname) AS Client_Name,
    COUNT(o.idOrder) AS Total_Orders,
    CASE
        WHEN COUNT(o.idOrder) >= 2 THEN 'Cliente Recorrente'
        WHEN COUNT(o.idOrder) = 1 THEN 'Cliente Novo'
        ELSE 'Cliente sem Pedidos'
    END AS Client_Category,
    los.orderStatus AS Last_Order_Status
FROM
    clients AS c
LEFT JOIN
    orders AS o ON c.idClient = o.idOrderClient
LEFT JOIN
    LastOrderStatus AS los ON c.idClient = los.idOrderClient AND los.rn = 1
GROUP BY
    c.Fname, c.Lname, los.orderStatus
ORDER BY
    Total_Orders DESC;

-- Pergunta 7 (Complexa): Quais clientes PJ estão gastando mais de R$ 100 em frete?
SELECT
    c.Fname AS Company_Name,
    SUM(o.sendValue) AS Total_Freight_Cost
FROM
    clients AS c
JOIN
    orders AS o ON c.idClient = o.idOrderClient
WHERE
    c.client_type = 'PJ'
GROUP BY
    c.Fname
HAVING
    SUM(o.sendValue) > 100;