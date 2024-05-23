CREATE TABLE CLIENTE(
	COD_CLIENTE SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(100) NOT NULL,
	CPF VARCHAR(15) NOT NULL UNIQUE,
	CONTATO VARCHAR(20) NOT NULL,
	EMAIL VARCHAR(50) NOT NULL
);	
INSERT INTO CLIENTE (NOME, CPF, CONTATO, EMAIL) VALUES 
	('Maria Silva', '123.456.789-10', '(11) 91234-5678', 'maria.silva@gmail.com'),
	('João Oliveira', '987.654.321-00', '(21) 99876-5432', 'joao.oliveira@gmail.com'),
	('Ana Santos', '456.789.123-45', '(31) 98765-4321', 'ana.santos@gmail.com'),
	('Pedro Souza', '654.321.987-00', '(41) 97654-3210', 'pedro.souza@gmail.com'),
	('Mariana Lima', '789.123.456-78', '(51) 96543-2109', 'mariana.lima@gmail.com'),
	('Carlos Pereira', '234.567.890-12', '(61) 95432-1098', 'carlos.pereira@gmail.com'),
	('Juliana Costa', '876.543.210-98', '(71) 94321-0987', 'juliana.costa@gmail.com'),
	('Fernando Oliveira', '345.678.901-23', '(81) 93210-9876', 'fernando.oliveira@gmail.com'),
	('Amanda Rodrigues', '567.890.123-45', '(91) 92109-8765', 'amanda.rodrigues@gmail.com'),
	('Lucas Almeida', '901.234.567-89', '(10) 91087-6543', 'lucas.almeida@gmail.com');

CREATE TABLE CARGO(
	COD_CARGO SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL,
	SALARIO NUMERIC(8,2) NOT NULL
);
INSERT INTO CARGO (NOME, SALARIO) VALUES 
	('Gerente', 5000.00),
	('Supervisor', 4000.00),
	('Assistente', 3000.00),
	('Caixa', 2500.00),
	('Estoquista', 2200.00);

CREATE TABLE LOJA(
	COD_LOJA SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL
);
INSERT INTO LOJA (NOME) VALUES 
	('Loja 1'),
	('Loja 2'),
	('Loja 3'),
	('Loja 4'),
	('Loja 5'); 

CREATE TABLE FUNCIONARIO(
	COD_FUNCIONARIO SERIAL NOT NULL PRIMARY KEY,
	COD_CARGO INT NOT NULL REFERENCES CARGO(COD_CARGO) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_LOJA INT NOT NULL REFERENCES LOJA(COD_LOJA) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	NOME VARCHAR(100) NOT NULL,
	CPF VARCHAR(15) NOT NULL UNIQUE,
	CONTATO VARCHAR(20) NOT NULL,
	EMAIL VARCHAR(50) NOT NULL
);
INSERT INTO FUNCIONARIO(COD_CARGO, COD_LOJA, NOME, CPF, CONTATO, EMAIL) VALUES
	(1, 1, 'João Silva', '123.456.789-01', '(11) 91234-5678', 'joao.silva@email.com'),
	(2, 1, 'Maria Santos', '987.654.321-09', '(22) 98765-4321', 'maria.santos@email.com'),
	(3, 2, 'Carlos Oliveira', '222.333.444-55', '(33) 87654-3210', 'carlos.oliveira@email.com'),
	(4, 2, 'Ana Pereira', '555.666.777-99', '(44) 76543-2109', 'ana.pereira@email.com'),
	(5, 3, 'Pedro Rocha', '111.222.333-44', '(55) 65432-1098', 'pedro.rocha@email.com'),
	(1, 3, 'Mariana Costa', '999.888.777-66', '(66) 54321-0987', 'mariana.costa@email.com'),
	(2, 4, 'Lucas Oliveira', '333.222.111-00', '(77) 43210-9876', 'lucas.oliveira@email.com'),
	(3, 4, 'Juliana Pereira', '777.888.999-00', '(88) 32109-8765', 'juliana.pereira@email.com'),
	(4, 5, 'Fernanda Santos', '444.555.666-33', '(99) 21098-7654', 'fernanda.santos@email.com'),
	(5, 5, 'Rafaela Almeida', '666.777.888-11', '(00) 10987-6543', 'rafaela.almeida@email.com');

CREATE TABLE PAGAMENTO(
	COD_PAGAMENTO SERIAL NOT NULL PRIMARY KEY,
	TIPO VARCHAR(50) NOT NULL
);
INSERT INTO PAGAMENTO (TIPO) VALUES 
	('Cartão de Crédito'),
	('Cartão de Débito'),
	('Dinheiro'),
	('Transferência Bancária'),
	('Pix');

CREATE TABLE CATEGORIA(
	COD_CATEGORIA SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(100) NOT NULL,
	DESCRICAO TEXT NOT NULL
);
INSERT INTO CATEGORIA (NOME, DESCRICAO) VALUES 
	('Camisetas', 'Camisetas de diversos estilos e cores'),
	('Calças Jeans', 'Calças jeans masculinas e femininas'),
	('Vestidos', 'Vestidos elegantes para diversas ocasiões'),
	('Sapatos', 'Calçados confortáveis e estilosos'),
	('Acessórios', 'Acessórios variados, como bolsas e cintos');

CREATE TABLE PRODUTO(
	COD_PRODUTO SERIAL NOT NULL PRIMARY KEY,
	COD_CATEGORIA INT NOT NULL REFERENCES CATEGORIA(COD_CATEGORIA) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	NOME VARCHAR(50) NOT NULL,
	VALOR_UNITARIO NUMERIC(8,2) NOT NULL
);
INSERT INTO PRODUTO (COD_CATEGORIA, NOME, VALOR_UNITARIO) VALUES 
	(1, 'Camiseta Básica', 29.99),
	(1, 'Camiseta Estampada', 39.99),
	(2, 'Calça Jeans Skinny', 89.99),
	(2, 'Calça Jeans Reta', 79.99),
	(3, 'Vestido Midi Floral', 129.99),
	(3, 'Vestido Longo de Festa', 199.99),
	(4, 'Sapato Social Masculino', 149.99),
	(4, 'Sapato Anabela Feminino', 119.99),
	(5, 'Bolsa Transversal', 79.99),
	(5, 'Cinto de Couro', 49.99);

CREATE TABLE ESTOQUE(
	COD_ESTOQUE SERIAL NOT NULL PRIMARY KEY, 
	COD_PRODUTO INT NOT NULL REFERENCES PRODUTO(COD_PRODUTO) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_LOJA INT NOT NULL REFERENCES LOJA(COD_LOJA) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	QUANTIDADE INT NOT NULL
);
INSERT INTO ESTOQUE (COD_PRODUTO, COD_LOJA, QUANTIDADE) VALUES 
	(1, 1, 100),
	(3, 1, 80),
	(6, 1, 80),
	(2, 2, 50),
	(4, 2, 70),
	(8, 2, 70),
	(9, 3, 120),
	(10, 3, 60),
	(5, 3, 60),
	(1, 1, 90),
	(1, 2, 110),
	(2, 3, 150),
	(10, 1, 85);

CREATE TABLE PEDIDO(
	COD_PEDIDO SERIAL NOT NULL PRIMARY KEY,
	COD_CLIENTE INT NOT NULL REFERENCES CLIENTE(COD_CLIENTE) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_FUNCIONARIO INT NOT NULL REFERENCES FUNCIONARIO(COD_FUNCIONARIO) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_PAGAMENTO INT NOT NULL REFERENCES PAGAMENTO(COD_PAGAMENTO) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	VALOR_TOTAL NUMERIC(8,2) NOT NULL,
	DATA_HORA TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	PAGO BOOLEAN DEFAULT FALSE NOT NULL
);
INSERT INTO PEDIDO (COD_CLIENTE, COD_FUNCIONARIO, COD_PAGAMENTO, VALOR_TOTAL, DATA_HORA, PAGO) VALUES 
	(1, 1, 1, 150.00, CURRENT_TIMESTAMP, TRUE),
	(2, 2, 2, 250.00, CURRENT_TIMESTAMP, TRUE),
	(3, 3, 3, 180.00, CURRENT_TIMESTAMP, TRUE),
	(4, 4, 4, 200.00, CURRENT_TIMESTAMP, FALSE),
	(5, 5, 5, 300.00, CURRENT_TIMESTAMP, FALSE);

CREATE TABLE ITEM_PEDIDO(
	COD_ITEM_PEDIDO SERIAL NOT NULL PRIMARY KEY,
	COD_PEDIDO INT NOT NULL REFERENCES PEDIDO(COD_PEDIDO) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_ESTOQUE INT NOT NULL REFERENCES ESTOQUE(COD_ESTOQUE) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	QUANTIDADE INT NOT NULL,
	VALOR_TOTAL_ITEM NUMERIC(8,2) NOT NULL
);
INSERT INTO ITEM_PEDIDO (COD_PEDIDO, COD_ESTOQUE, QUANTIDADE, VALOR_TOTAL_ITEM) VALUES 
	(1, 1, 2, 50.00),
	(1, 2, 1, 100.00),
	(2, 3, 1, 150.00),
	(3, 4, 2, 120.00),
	(4, 5, 1, 200.00),
	(5, 6, 3, 300.00);
---------------------------------------------------------------------------------------------------------------------------------
/*FUNCTIONS

CREATE OR REPLACE FUNCTION FUNCTION_NAME(PARAMETROS INT)
RETURNS VOID AS $$
DECLARE 
	VARIAVEIS
BEGIN 
	LOGICA
END;
$$
LANGUAGE PLPGSQL;

CLIENTE, CARGO, LOJA, FUNCIONARIO, PAGAMENTO, CATEGORIA, PRODUTO, ESTOQUE, PEDIDO, ITEM_PEDIDO
*/
--CRUD's (INSERT, UPDATE, DELETE)

CREATE OR REPLACE FUNCTION ADD_PRODUTO(NOME_CAT VARCHAR(100), NOME_P VARCHAR(50), VALOR_P NUMERIC(8,2))
RETURNS VOID AS $$
DECLARE
	COD_CAT INT;
BEGIN
	IF NOT EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NOME_P) THEN
		IF EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NOME_CAT) THEN
			SELECT COD_CATEGORIA INTO COD_CAT FROM CATEGORIA WHERE NOME ILIKE NOME_CAT;
			INSERT INTO CATEGORIA(COD_CATEGORIA, NOME, VALOR_UNITARIO) VALUES(COD_CAT, NOME_P, VALOR_P);
		ELSE 
			RAISE EXCEPTION 'A CATEGORIA NÃO EXISTE.';
		END IF;
	ELSE 
		RAISE EXCEPTION 'O PRODUTO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_CATEGORIA(NOME_C VARCHAR(50), DESC_C TEXT) --new
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NOME_C) THEN
		INSERT INTO CATEGORIA(NOME, DESCRICAO) VALUES(NOME_C, DESC_C);
	ELSE 
		RAISE EXCEPTION 'A CATEGORIA JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT ADD_CATEGORIA('Camisetas', 'Tecido de algodao, GG e XGG')

CREATE OR REPLACE FUNCTION ADD_PAGAMENTO(TIPO_P VARCHAR(50)) --new
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE TIPO ILIKE TIPO_P) THEN
		INSERT INTO PAGAMENTO(TIPO) VALUES(TIPO_P);
	ELSE 
		RAISE EXCEPTION 'O PAGAMENTO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT ADD_PAGAMENTO('Dinheiro');

CREATE OR REPLACE FUNCTION ADD_CLIENTE(NOME_C VARCHAR(100), CPF_C VARCHAR(15), CONTATO_C VARCHAR(20), EMAIL_C VARCHAR(50))
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM CLIENTE WHERE CPF_C = CPF ) THEN
		INSERT INTO CLIENTE(NOME, CPF, CONTATO, EMAIL) VALUES (NOME_C, CPF_C, CONTATO_C, EMAIL_C);
	ELSE
		RAISE EXCEPTION 'CLIENTE JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT ADD_CLIENTE('Luiza Marques', '123.456.789-10', '86988458900', 'luizamarquesthe@gmail.com')


CREATE OR REPLACE FUNCTION ADD_CARGO(NOME_C VARCHAR(100), SALARIO_C NUMERIC(8,2))
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NOME_C) THEN 
		INSERT INTO CARGO (NOME, SALARIO) VALUES (NOME_C, SALARIO_C);
	ELSE 
		RAISE EXCEPTION 'O CARGO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT ADD_CARGO('Atendente', 1250.00);
	
CREATE OR REPLACE FUNCTION ADD_LOJA(NOME_L VARCHAR(50))
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NOME_L) THEN 
		INSERT INTO LOJA(NOME) VALUES(NOME_L);
	ELSE 
		RAISE EXCEPTION 'A LOJA JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT ADD_LOJA('Loja 1');

CREATE OR REPLACE FUNCTION ADD_FUNCIONARIO(NOME_CAR VARCHAR(100), NOME_LOJ VARCHAR(50), NOME_F VARCHAR(100), CPF_F VARCHAR(50), CONTATO_F VARCHAR(50), EMAIL_F VARCHAR(50))
RETURNS VOID AS $$
DECLARE 
	COD_CAR INT;
	COD_LOJ INT;
BEGIN
	IF NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE CPF = CPF_F) THEN 
		IF EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NOME_CAR) THEN
			IF EXISTS(SELECT * FROM LOJA WHERE NOME = NOME_LOJ) THEN
				SELECT COD_CARGO INTO COD_CAR FROM CARGO WHERE NOME ILIKE NOME_CAR;
				SELECT COD_LOJA INTO COD_LOJ FROM LOJA WHERE NOME ILIKE NOME_LOJ;
				INSERT INTO FUNCIONARIO (COD_CARGO, COD_LOJA, NOME, CPF, CONTATO, EMAIL) VALUES(COD_CAR, COD_LOJ, NOME_F, CPF_F, CONTATO_F, EMAIL_F);
			ELSE 
				RAISE EXCEPTION 'A LOJA NÃO EXISTE.';
			END IF;
		ELSE
			RAISE EXCEPTION 'O CARGO NÃO EXISTE.';
		END IF;
	ELSE
		RAISE EXCEPTION 'O FUNCIONARIO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT ADD_FUNCIONARIO('Supervisor', 'Loja 5', 'Yarah Gomes', '120.456.789-06', '(89) 99499-0820', 'yarahgomes@gmail.com')