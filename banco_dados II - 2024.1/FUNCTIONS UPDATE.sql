------------------------------------------------FUNCTIONS UPDATE-----------------------------------------------------
CREATE OR REPLACE FUNCTION UPDATE_CLIENTE(
	COD_C INT, NOME_C VARCHAR(100) DEFAULT NULL,
	CPF_C VARCHAR(15) DEFAULT NULL, 
	CONTATO_C VARCHAR(20) DEFAULT NULL, 
	EMAIL_C VARCHAR(50) DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM CLIENTE WHERE COD = COD_C ) THEN
		RAISE EXCEPTION 'O CLIENTE DE CÓDIGO % NÃO EXISTE.', COD_C;
	ELSE
		UPDATE CLIENTE SET
			NOME = COALESCE(NOME_C, NOME),
			CPF = COALESCE(CPF_C, CPF),
			CONTATO = COALESCE(CONTATO_C, CONTATO),
			EMAIL = COALESCE(EMAIL_C, EMAIL)
		WHERE COD = COD_C;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT UPDATE_CLIENTE(1, NULL, NULL,'(86) 91234-5678', 'mariadacostasilva@gmail.com')

CREATE OR REPLACE FUNCTION UPDATE_CARGO(
	COD_CAR INT, 
	NOME_CAR VARCHAR(50) DEFAULT NULL, 
	SALARIO_C NUMERIC(8,2) DEFAULT NULL)
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM CARGO WHERE COD = COD_CAR) THEN 
		RAISE EXCEPTION 'O CARGO DE CÓDIGO % NÃO EXISTE.', COD_CAR;
	ELSE 
		UPDATE CARGO SET 
			NOME = COALESCE(NOME_CAR, NOME),
			SALARIO = COALESCE(SALARIO_C, SALARIO)
		WHERE COD = COD_CAR;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT UPDATE_CARGO(1, 'Gerente',NULL)
	
CREATE OR REPLACE FUNCTION UPDATE_LOJA(
	COD_L INT,
	NOME_L VARCHAR(50) DEFAULT NULL)
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM LOJA WHERE COD = COD_L) THEN
		RAISE EXCEPTION 'A LOJA DE CÓDIGO % NÃO EXISTE.', COD_L;
	ELSE
		UPDATE LOJA SET 
			NOME = COALESCE(NOME_L, NOME)
		WHERE COD = COD_L;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT UPDATE_LOJA(9, 'Loja 1')

CREATE OR REPLACE FUNCTION UPDATE_FUNCIONARIO(
	COD_F INT,
	CPF_F VARCHAR(50) DEFAULT NULL,
	NOME_CAR VARCHAR(50) DEFAULT NULL, 
	NOME_LOJ VARCHAR(50) DEFAULT NULL, 
	NOME_F VARCHAR(50) DEFAULT NULL,  
	CONTATO_F VARCHAR(50) DEFAULT NULL, 
	EMAIL_F VARCHAR(50) DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
	COD_CAR INT; 
	COD_LOJ INT;
BEGIN	
	IF NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE COD = COD_F) THEN
		RAISE EXCEPTION 'O FUNCIONARIO NÃO EXISTE.';
	ELSE
		IF NOME_CAR IS NOT NULL THEN
			SELECT COD INTO COD_CAR FROM CARGO WHERE NOME ILIKE NOME_CAR;
	
			IF EXISTS(SELECT * FROM CARGO WHERE COD = COD_CAR) THEN
				UPDATE FUNCIONARIO SET COD_CARGO = COD_CAR WHERE COD = COD_F;
			ELSE
				RAISE EXCEPTION 'O CARGO % NÃO EXISTE.', NOME_CAR;
			END IF;
		END IF;

		IF NOME_LOJ IS NOT NULL THEN
			SELECT COD INTO COD_LOJ FROM LOJA WHERE NOME ILIKE NOME_LOJ;
	
			IF EXISTS(SELECT * FROM LOJA WHERE COD = COD_LOJ) THEN
				UPDATE FUNCIONARIO SET COD_LOJA = COD_LOJ WHERE COD = COD_F;
			ELSE
				RAISE EXCEPTION 'A LOJA % NÃO EXISTE.', NOME_LOJ;
			END IF;
		END IF;
	
		IF NOME_F IS NOT NULL THEN
			UPDATE FUNCIONARIO SET NOME = NOME_F WHERE COD = COD_F;
		END IF;
	
		IF CPF_F IS NOT NULL THEN
			UPDATE FUNCIONARIO SET CPF = CPF_F WHERE COD = COD_F;
		END IF;
	
		IF CONTATO_F IS NOT NULL THEN
			UPDATE FUNCIONARIO SET CONTATO = CONTATO_F WHERE COD = COD_F;
		END IF;
	
		IF EMAIL_F IS NOT NULL THEN
			UPDATE FUNCIONARIO SET EMAIL = EMAIL_F WHERE COD = COD_F;
		END IF;

		RAISE EXCEPTION 'POR FAVOR, INSIRA OS DADOS CORRETAMENTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT UPDATE_FUNCIONARIO(1, '098765432-21',NULL, NULL, NULL, NULL, NULL)

CREATE OR REPLACE FUNCTION UPDATE_CATEGORIA(
	COD_C INT, 
	NOME_C VARCHAR(50) DEFAULT NULL, 
	DESC_C TEXT DEFAULT NULL)
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM CATEGORIA WHERE COD = COD_C) THEN
		RAISE EXCEPTION 'A CATEGORIA NÃO EXISTE.';
	ELSE
		UPDATE CATEGORIA SET 
			NOME = COALESCE(NOME_C, NOME),
			DESCRICAO = COALESCE(DESC_C, DESCRICAO)
		WHERE COD = COD_C;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT UPDATE_CATEGORIA(90, 'Camisetas','Camisetas de tamanho P, PP, M, G e GG')
	
CREATE OR REPLACE FUNCTION UPDATE_PRODUTO(
	COD_P INT,
	NOME_P VARCHAR(100) DEFAULT NULL, 
	VALOR_P NUMERIC(8,2) DEFAULT NULL,
	NOME_CAT VARCHAR(100) DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
	COD_CAT INT;
BEGIN 
	IF NOT EXISTS(SELECT * FROM PRODUTO WHERE COD = COD_P) THEN
		RAISE EXCEPTION 'O PRODUTO % NÃO EXISTE.', NOME_P;
	ELSE 
		IF NOME_P IS NOT NULL OR VALOR_P IS NOT NULL THEN
			UPDATE PRODUTO SET 
				NOME = COALESCE(NOME_P, NOME),
				VALOR_UNITARIO = COALESCE(VALOR_P, VALOR_UNITARIO)
			WHERE COD = COD_P;
		END IF;

		IF NOME_CAT IS NOT NULL THEN
			SELECT COD INTO COD_CAT FROM CATEGORIA WHERE NOME ILIKE NOME_CAT;

			IF EXISTS(SELECT * FROM CATEGORIA WHERE COD = COD_CAT) THEN
				UPDATE PRODUTO SET COD = COD_CAT 
				WHERE COD = COD_P;
			ELSE
				RAISE EXCEPTION 'A CATEGORIA % NÃO EXISTE.',NOME_CAT;
			END IF;
		END IF;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT UPDATE_PRODUTO(1,NULL,NULL,'Vestido longos')

CREATE OR REPLACE FUNCTION UPDATE_PAGAMENTO(
	COD_PAG INT, 
	TIPO_P VARCHAR(50) DEFAULT NULL)
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE COD = COD_PAG) THEN
		RAISE EXCEPTION 'O TIPO DE PAGAMENTO NÃO EXISTE.';
	ELSE 
		UPDATE PAGAMENTO SET TIPO = COD = COD_PAG;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT UPDATE_PAGAMENTO(9, 'TED')
	
CREATE OR REPLACE FUNCTION UPDATE_ESTOQUE(
	COD_E INT,
	QUANT INT DEFAULT NULL,
	NOME_PROD VARCHAR(100) DEFAULT NULL, 
	NOME_LOJ VARCHAR(50) DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
	COD_PROD INT;
	COD_LOJ INT;
BEGIN
	IF NOT EXISTS(SELECT * FROM ESTOQUE WHERE COD = COD_E) THEN 
		RAISE EXCEPTION 'O PRODUTO NÃO EXISTE.';
	ELSE 
		IF QUANT IS NOT NULL THEN
			UPDATE ESTOQUE SET QUANTIDADE = QUANT WHERE COD = COD_PROD;
		END IF;
	
		IF NOME_PROD IS NOT NULL THEN
			SELECT COD INTO COD_PROD FROM PRODUTO WHERE NOME ILIKE NOME_PROD;

			IF NOT EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NOME_PROD) THEN
				RAISE EXCEPTION 'O PRODUTO % NÃO EXISTE.', NOME_PROD;
			ELSE 
				UPDATE ESTOQUE SET COD_PRODUTO = COD_PROD WHERE COD = COD_E;
			END IF;
		END IF;

		IF NOME_LOJ IS NOT NULL THEN
			SELECT COD INTO COD_LOJ FROM LOJA WHERE NOME ILIKE NOME_LOJ;

			IF NOT EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NOME_LOJ) THEN 
				RAISE EXCEPTION 'A LOJA % NÃO EXISTE.', NOME_LOJ;
			ELSE
				UPDATE ESTOQUE SET COD_LOJA = COD_LOJ WHERE COD = COD_E;
			END IF;
		END IF;

		--RAISE EXCEPTION 'POR FAVOR, INSIRA OS DADOS CORRETAMENTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--ex:
SELECT UPDATE_ESTOQUE(1, NULL,'Camiseta Estampada',NULL)