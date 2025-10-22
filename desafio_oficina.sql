-- Database: desafio_oficina

-- DROP DATABASE IF EXISTS desafio_oficina;

CREATE DATABASE desafio_oficina
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
-- SCRIPT SQL FINAL - DESAFIO DE PROJETO OFICINA (POSTGRESQL)
-- =====================================================================
-- Autor PEDRO LUIZ
-- -----------------------------------------------------
-- PARTE 1: DDL (Data Definition Language)
-- -----------------------------------------------------

CREATE TYPE os_status_enum AS ENUM ('Aguardando Análise', 'Aguardando Aprovação', 'Em Execução', 'Concluído', 'Cancelado');

CREATE TABLE clients (
    idClient SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    CPF CHAR(11) UNIQUE NOT NULL,
    Contact VARCHAR(20),
    Address VARCHAR(255)
);

CREATE TABLE vehicles (
    idVehicle SERIAL PRIMARY KEY,
    idClient INT NOT NULL,
    LicensePlate CHAR(7) UNIQUE NOT NULL,
    Model VARCHAR(50),
    Brand VARCHAR(50),
    VehicleYear INT,
    CONSTRAINT fk_vehicle_client FOREIGN KEY (idClient) REFERENCES clients(idClient)
);

CREATE TABLE mechanics (
    idMechanic SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Specialty VARCHAR(50)
);

CREATE TABLE work_orders (
    idOrder SERIAL PRIMARY KEY,
    idVehicle INT NOT NULL,
    IssueDate DATE NOT NULL,
    ProblemDescription TEXT,
    Status os_status_enum DEFAULT 'Aguardando Análise',
    CompletionDate DATE,
    CONSTRAINT fk_order_vehicle FOREIGN KEY (idVehicle) REFERENCES vehicles(idVehicle)
);

CREATE TABLE parts (
    idPart SERIAL PRIMARY KEY,
    PartName VARCHAR(100) NOT NULL,
    StockQuantity INT DEFAULT 0,
    PartValue DECIMAL(10, 2) NOT NULL
);

CREATE TABLE services (
    idService SERIAL PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL,
    ServiceValue DECIMAL(10, 2) NOT NULL
);

CREATE TABLE os_services (
    idOrder INT,
    idService INT,
    PRIMARY KEY (idOrder, idService),
    CONSTRAINT fk_os_service_order FOREIGN KEY (idOrder) REFERENCES work_orders(idOrder),
    CONSTRAINT fk_os_service_service FOREIGN KEY (idService) REFERENCES services(idService)
);

CREATE TABLE os_parts (
    idOrder INT,
    idPart INT,
    QuantityUsed INT DEFAULT 1,
    PRIMARY KEY (idOrder, idPart),
    CONSTRAINT fk_os_part_order FOREIGN KEY (idOrder) REFERENCES work_orders(idOrder),
    CONSTRAINT fk_os_part_part FOREIGN KEY (idPart) REFERENCES parts(idPart)
);

CREATE TABLE os_team (
    idOrder INT,
    idMechanic INT,
    PRIMARY KEY (idOrder, idMechanic),
    CONSTRAINT fk_os_team_order FOREIGN KEY (idOrder) REFERENCES work_orders(idOrder),
    CONSTRAINT fk_os_team_mechanic FOREIGN KEY (idMechanic) REFERENCES mechanics(idMechanic)
);


-- -----------------------------------------------------
-- PARTE 2: DML (Data Manipulation Language)
-- -----------------------------------------------------

INSERT INTO clients (FullName, CPF, Contact, Address) VALUES
('João da Silva', '11122233344', '35991234567', 'Rua A, 123'),
('Maria Oliveira', '55566677788', '35998765432', 'Avenida B, 456'),
('Carlos Pereira', '99988877766', '35999887766', 'Praça C, 789');

INSERT INTO vehicles (idClient, LicensePlate, Model, Brand, VehicleYear) VALUES
(1, 'ABC1D23', 'Gol', 'Volkswagen', 2020),
(1, 'XYZ9A87', 'Strada', 'Fiat', 2022),
(2, 'QWE4R56', 'Onix', 'Chevrolet', 2021);

INSERT INTO mechanics (FullName, Specialty) VALUES
('Pedro Alves', 'Motor'),
('Ana Souza', 'Elétrica'),
('José Lima', 'Suspensão');

INSERT INTO parts (PartName, StockQuantity, PartValue) VALUES
('Óleo 5W30 Sintético', 100, 45.00),
('Filtro de Óleo', 80, 25.00),
('Pastilha de Freio Dianteira', 50, 120.00),
('Vela de Ignição', 200, 15.00);

INSERT INTO services (ServiceName, ServiceValue) VALUES
('Troca de Óleo e Filtro', 80.00),
('Revisão de Freios', 100.00),
('Diagnóstico Elétrico', 120.00),
('Alinhamento e Balanceamento', 90.00);

INSERT INTO work_orders (idVehicle, IssueDate, ProblemDescription, Status, CompletionDate) VALUES
(1, '2025-10-20', 'Ruído no freio dianteiro.', 'Concluído', '2025-10-21'),
(2, '2025-10-21', 'Falha no sistema elétrico, luzes piscando.', 'Em Execução', NULL),
(3, '2025-10-22', 'Manutenção periódica, troca de óleo.', 'Aguardando Aprovação', NULL),
(1, '2025-08-15', 'Revisão geral antes de viagem.', 'Concluído', '2025-08-17');

INSERT INTO os_services (idOrder, idService) VALUES (1, 2), (2, 3), (3, 1), (4, 1), (4, 4);
INSERT INTO os_parts (idOrder, idPart, QuantityUsed) VALUES (1, 3, 1), (3, 1, 4), (3, 2, 1), (4, 1, 4), (4, 2, 1);
INSERT INTO os_team (idOrder, idMechanic) VALUES (1, 3), (2, 2), (3, 1), (4, 1), (4, 3);


-- -----------------------------------------------------
-- PARTE 3: DQL (Data Query Language)
-- -----------------------------------------------------

-- Pergunta 1: Listar todas as ordens de serviço que ainda não foram concluídas, mostrando o nome do cliente e o modelo do veículo.
SELECT 
    wo.idOrder,
    wo.IssueDate,
    wo.Status,
    c.FullName AS ClientName,
    v.Model AS VehicleModel,
    v.LicensePlate
FROM work_orders AS wo
JOIN vehicles AS v ON wo.idVehicle = v.idVehicle
JOIN clients AS c ON v.idClient = c.idClient
WHERE wo.Status <> 'Concluído' AND wo.Status <> 'Cancelado'
ORDER BY wo.IssueDate;

-- Pergunta 2: Calcular o valor total de cada ordem de serviço concluída (soma do valor dos serviços e das peças utilizadas).
SELECT 
    wo.idOrder,
    c.FullName AS ClientName,
    v.Model AS VehicleModel,
    (SELECT SUM(s.ServiceValue) FROM os_services os_s JOIN services s ON os_s.idService = s.idService WHERE os_s.idOrder = wo.idOrder) AS TotalServicesValue,
    (SELECT SUM(p.PartValue * op.QuantityUsed) FROM os_parts op JOIN parts p ON op.idPart = p.idPart WHERE op.idOrder = wo.idOrder) AS TotalPartsValue,
    COALESCE((SELECT SUM(s.ServiceValue) FROM os_services os_s JOIN services s ON os_s.idService = s.idService WHERE os_s.idOrder = wo.idOrder), 0) + 
    COALESCE((SELECT SUM(p.PartValue * op.QuantityUsed) FROM os_parts op JOIN parts p ON op.idPart = p.idPart WHERE op.idOrder = wo.idOrder), 0) AS GrandTotal
FROM work_orders AS wo
JOIN vehicles AS v ON wo.idVehicle = v.idVehicle
JOIN clients AS c ON v.idClient = c.idClient
WHERE wo.Status = 'Concluído'
ORDER BY GrandTotal DESC;

-- Pergunta 3: Quais mecânicos trabalharam em mais de uma ordem de serviço?
SELECT
    m.FullName AS MechanicName,
    m.Specialty,
    COUNT(ot.idOrder) AS NumberOfOrders
FROM mechanics AS m
JOIN os_team AS ot ON m.idMechanic = ot.idMechanic
GROUP BY m.idMechanic, m.FullName, m.Specialty
HAVING COUNT(ot.idOrder) > 1
ORDER BY NumberOfOrders DESC;

-- Pergunta 4: Mostrar um relatório detalhado da Ordem de Serviço de ID 1.
SELECT
    wo.idOrder,
    wo.Status,
    c.FullName AS Client,
    v.Model AS Vehicle,
    s.ServiceName,
    s.ServiceValue
FROM work_orders wo
JOIN vehicles v ON wo.idVehicle = v.idVehicle
JOIN clients c ON v.idClient = c.idClient
JOIN os_services os ON wo.idOrder = os.idOrder
JOIN services s ON os.idService = s.idService
WHERE wo.idOrder = 1
UNION ALL
SELECT
    wo.idOrder,
    wo.Status,
    c.FullName,
    v.Model,
    p.PartName,
    p.PartValue * op.QuantityUsed
FROM work_orders wo
JOIN vehicles v ON wo.idVehicle = v.idVehicle
JOIN clients c ON v.idClient = c.idClient
JOIN os_parts op ON wo.idOrder = op.idOrder
JOIN parts p ON op.idPart = p.idPart
WHERE wo.idOrder = 1;

-- Pergunta 5: Quais são os clientes que mais gastaram na oficina (Top 3)?
WITH OrderTotals AS (
    SELECT
        wo.idOrder,
        COALESCE(SUM(s.ServiceValue), 0) AS TotalServices,
        COALESCE(SUM(p.PartValue * op.QuantityUsed), 0) AS TotalParts
    FROM work_orders AS wo
    LEFT JOIN os_services os ON wo.idOrder = os.idOrder
    LEFT JOIN services s ON os.idService = s.idService
    LEFT JOIN os_parts op ON wo.idOrder = op.idOrder
    LEFT JOIN parts p ON op.idPart = p.idPart
    WHERE wo.Status = 'Concluído'
    GROUP BY wo.idOrder
)
SELECT
    c.FullName AS ClientName,
    SUM(ot.TotalServices + ot.TotalParts) AS TotalSpent
FROM clients AS c
JOIN vehicles AS v ON c.idClient = v.idClient
JOIN work_orders AS wo ON v.idVehicle = wo.idVehicle
JOIN OrderTotals AS ot ON wo.idOrder = ot.idOrder
GROUP BY c.FullName
ORDER BY TotalSpent DESC
LIMIT 3;

-- Pergunta 6: Quais peças estão com estoque baixo (menos de 50 unidades)?
SELECT
    PartName,
    StockQuantity
FROM parts
WHERE StockQuantity < 50
ORDER BY StockQuantity ASC;

-- Pergunta 7: Qual é o serviço mais solicitado pela oficina?
SELECT
    s.ServiceName,
    COUNT(os.idOrder) AS TimesRequested
FROM services AS s
JOIN os_services AS os ON s.idService = os.idService
GROUP BY s.ServiceName
ORDER BY TimesRequested DESC;