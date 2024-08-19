------------------------------------------------FUNCTIONS UPDATE-----------------------------------------------------
CREATE OR REPLACE FUNCTION UPDATE_CLIENTE(
	CPF_C VARCHAR(15), 
	NOME_C VARCHAR(100) DEFAULT NULL,
	CONTATO_C VARCHAR(20) DEFAULT NULL, 
	EMAIL_C VARCHAR(50) DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM CLIENTE WHERE CPF ILIKE CPF_C ) THEN
		RAISE EXCEPTION 'O CLIENTE % NÃO EXISTE.', CPF_C;
	ELSE
		UPDATE CLIENTE SET
			NOME = COALESCE(NOME_C, NOME),
			CPF = COALESCE(CPF_C, CPF),
			CONTATO = COALESCE(CONTATO_C, CONTATO),
			EMAIL = COALESCE(EMAIL_C, EMAIL)
		WHERE CPF ILIKE CPF_C;

	RAISE NOTICE 'DADOS DE CLIENTE ATUALIZADO COM SUCESSO.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
	
CREATE OR REPLACE FUNCTION UPDATE_CARGO(
	NOME_CAR VARCHAR(50), 
	SALARIO_C NUMERIC(8,2) DEFAULT NULL,
	COMISSAO_C NUMERIC(4,2) DEFAULT NULL)
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NOME_CAR) THEN 
		RAISE EXCEPTION 'O CARGO % NÃO EXISTE.', NOME_CAR;
	ELSE 
		UPDATE CARGO SET 
			NOME = COALESCE(NOME_CAR, NOME),
			SALARIO = COALESCE(SALARIO_C, SALARIO),
			COMISSAO = COALESCE(COMISSAO_C, COMISSAO)
		WHERE NOME ILIKE NOME_CAR;

		RAISE NOTICE 'DADOS DO CARGO ATUALIZADO COM SUCESSO.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
	
CREATE OR REPLACE FUNCTION UPDATE_LOJA(
	NOME_L VARCHAR(50),
	CNPJ_L VARCHAR(18) DEFAULT NULL,
	ENDERECO_L TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NOME_L) THEN
		RAISE EXCEPTION 'A LOJA % NÃO EXISTE.', NOME_L;
	ELSE
		UPDATE LOJA SET 
			NOME = COALESCE(NOME_L, NOME),
			CNPJ = COALESCE(CNPJ_L, CNPJ),
			ENDERECO = COALESCE(ENDERECO_L, ENDERECO)
		WHERE NOME ILIKE NOME_L;

		RAISE NOTICE 'DADOS DA LOJA ATUALIZADA COM SUCESSO.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
	
CREATE OR REPLACE FUNCTION UPDATE_FUNCIONARIO(
	CPF_F VARCHAR(50), 
	NOME_F VARCHAR(50) DEFAULT NULL,  
	CONTATO_F VARCHAR(50) DEFAULT NULL, 
	EMAIL_F VARCHAR(50) DEFAULT NULL,
	NOME_CAR VARCHAR(50) DEFAULT NULL, 
	NOME_LOJ VARCHAR(50) DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
	COD_CAR INT; 
	COD_LOJ INT;
BEGIN	
	IF NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE CPF ILIKE CPF_F) THEN
		RAISE EXCEPTION 'O FUNCIONARIO NÃO EXISTE.';
	ELSE
		IF NOME_F IS NOT NULL THEN
			UPDATE FUNCIONARIO SET NOME = NOME_F WHERE CPF ILIKE CPF_F;
			RAISE NOTICE 'DADOS DO FUNCIONARIO ATUALIZADOS COM SUCESSO.';
		END IF;
	
		IF CONTATO_F IS NOT NULL THEN
			UPDATE FUNCIONARIO SET CONTATO = CONTATO_F WHERE CPF ILIKE CPF_F;
			RAISE NOTICE 'DADOS DO FUNCIONARIO ATUALIZADOS COM SUCESSO.';
		END IF;
	
		IF EMAIL_F IS NOT NULL THEN
			UPDATE FUNCIONARIO SET EMAIL = EMAIL_F WHERE CPF ILIKE CPF_F;
			RAISE NOTICE 'DADOS DO FUNCIONARIO ATUALIZADOS COM SUCESSO.';
		END IF;
	
		IF NOME_CAR IS NOT NULL THEN
			SELECT COD INTO COD_CAR FROM CARGO WHERE NOME ILIKE NOME_CAR;
	
			IF EXISTS(SELECT * FROM CARGO WHERE COD = COD_CAR) THEN
				UPDATE FUNCIONARIO SET COD_CARGO = COD_CAR WHERE CPF ILIKE CPF_F;
				RAISE NOTICE 'DADOS DO FUNCIONARIO ATUALIZADOS COM SUCESSO.';
			ELSE
				RAISE EXCEPTION 'O CARGO % NÃO EXISTE.', NOME_CAR;
			END IF;
		END IF;

		IF NOME_LOJ IS NOT NULL THEN
			SELECT COD INTO COD_LOJ FROM LOJA WHERE NOME ILIKE NOME_LOJ;
	
			IF EXISTS(SELECT * FROM LOJA WHERE COD = COD_LOJ) THEN
				UPDATE FUNCIONARIO SET COD_LOJA = COD_LOJ WHERE CPF ILIKE CPF_F;
				RAISE NOTICE 'DADOS DO FUNCIONARIO ATUALIZADOS COM SUCESSO.';
			ELSE
				RAISE EXCEPTION 'A LOJA % NÃO EXISTE.', NOME_LOJ;
			END IF;
		END IF;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION UPDATE_CATEGORIA(
	NOME_C VARCHAR(50), 
	DESC_C TEXT DEFAULT NULL)
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NOME_C) THEN
		RAISE EXCEPTION 'A CATEGORIA NÃO EXISTE.';
	ELSE
		UPDATE CATEGORIA SET 
			NOME = COALESCE(NOME_C, NOME),
			DESCRICAO = COALESCE(DESC_C, DESCRICAO)
		WHERE NOME ILIKE NOME_C;
		RAISE NOTICE 'DADOS DE CATEGORIA ATUALIZADOS COM SUCESSO.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;
	
CREATE OR REPLACE FUNCTION UPDATE_PRODUTO(
	NOME_P VARCHAR(100), 
	VALOR_P NUMERIC(8,2) DEFAULT NULL,
	NOME_CAT VARCHAR(100) DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
	COD_CAT INT;
BEGIN 
	IF NOT EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NOME_P) THEN
		RAISE EXCEPTION 'O PRODUTO % NÃO EXISTE.', NOME_P;
	ELSE 
		IF NOME_P IS NOT NULL OR VALOR_P IS NOT NULL THEN
			UPDATE PRODUTO SET 
				NOME = COALESCE(NOME_P, NOME),
				VALOR_UNITARIO = COALESCE(VALOR_P, VALOR_UNITARIO)
			WHERE NOME ILIKE NOME_P;
			RAISE NOTICE 'DADOS DE PRODUTO ATUALIZADOS COM SUCESSO.';
		END IF;

		IF NOME_CAT IS NOT NULL THEN
			SELECT COD INTO COD_CAT FROM CATEGORIA WHERE NOME ILIKE NOME_CAT;

			IF EXISTS(SELECT * FROM CATEGORIA WHERE COD = COD_CAT) THEN
				UPDATE PRODUTO SET COD = COD_CAT 
				WHERE NOME ILIKE NOME_P;
				RAISE NOTICE 'DADOS DE PRODUTO ATUALIZADOS COM SUCESSO.';
			ELSE
				RAISE EXCEPTION 'A CATEGORIA % NÃO EXISTE.',NOME_CAT;
			END IF;
		END IF;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION UPDATE_PAGAMENTO(
	NOME_PAG VARCHAR(50) DEFAULT NUL)
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE NOME = NOME_PAG) THEN
		RAISE EXCEPTION 'O TIPO DE PAGAMENTO NÃO EXISTE.';
	ELSE 
		UPDATE PAGAMENTO SET NOME = NOME_PAG WHERE NOME = NOME_PAG;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

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
	END IF;
END;
$$ LANGUAGE PLPGSQL;

---------------------------------------------FUNCÃO ALTERAR----------------------------------------------------------

CREATE OR REPLACE FUNCTION ALTERAR(--LOJA
	TABELA VARCHAR(50),
	NOME VARCHAR(100),
	CNPJ VARCHAR(18),
	ENDERECO TEXT)
RETURNS VOID AS $$
BEGIN
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		IF NOME IS NOT NULL THEN
			PERFORM UPDATE_LOJA(NOME, CNPJ, ENDERECO);
		ELSE 
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;	
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ALTERAR(--PAGAMENTO
	TABELA VARCHAR(50),
	NOME VARCHAR(100))
RETURNS VOID AS $$
BEGIN
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		IF NOME IS NOT NULL THEN
			PERFORM UPDATE_PAGAMENTO(NOME);
		ELSE
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;	
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ALTERAR(--CLIENTE
	TABELA VARCHAR(50),
	CPF VARCHAR(15), 
	NOME VARCHAR(100), 
	CONTATO VARCHAR(20), 
	EMAIL VARCHAR(50)) 
RETURNS VOID AS $$
DECLARE
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		IF (NOME IS NOT NULL OR CPF IS NOT NULL OR CONTATO IS NOT NULL OR EMAIL IS NOT NULL) THEN
			PERFORM UPDATE_CLIENTE(CPF,NOME,CONTATO,EMAIL);
		ELSE
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ALTERAR(--FUNCIONARIO
	TABELA VARCHAR(50), 
	CPF VARCHAR(15), 
	NOME VARCHAR(100), 
	CONTATO VARCHAR(20), 
	EMAIL VARCHAR(50),
	NOME_CAR VARCHAR(50), 
	NOME_LOJ VARCHAR(10)) 
RETURNS VOID AS $$
DECLARE
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		IF (NOME IS NOT NULL OR CPF IS NOT NULL OR CONTATO IS NOT NULL OR EMAIL IS NOT NULL OR NOME_CAR IS NOT NULL OR NOME_LOJ IS NOT NULL) THEN
			PERFORM UPDATE_FUNCIONARIO(CPF, NOME, CONTATO, EMAIL, NOME_CAR, NOME_LOJ);
		ELSE 
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ALTERAR(--CARGO
	TABELA VARCHAR(50), 
	NOME VARCHAR(100), 
	SALARIO NUMERIC(8,2),
	COMISSAO NUMERIC(4,2))
RETURNS VOID AS $$
DECLARE
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		IF NOME IS NOT NULL OR SALARIO IS NOT NULL THEN
			PERFORM UPDATE_CARGO(NOME, SALARIO, COMISSAO);
		ELSE
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ALTERAR(--CATEGORIA
	TABELA VARCHAR(50),
	NOME VARCHAR(100), 
	DESCRICAO VARCHAR(150)) 
RETURNS VOID AS $$
DECLARE
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		IF NOME IS NOT NULL OR DESCRICAO IS NOT NULL THEN
			PERFORM UPDATE_CATEGORIA(NOME, DESCRICAO);
		ELSE
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ALTERAR(--PRODUTO
	TABELA VARCHAR(50),
	PRODUTO VARCHAR(100), 
	VALOR NUMERIC(8,2),
	CATEGORIA VARCHAR(100))
RETURNS VOID AS $$
DECLARE
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		IF PRODUTO IS NOT NULL OR VALOR IS NOT NULL OR CATEGORIA IS NOT NULL THEN
			PERFORM UPDATE_PRODUTO(PRODUTO, VALOR, CATEGORIA);
		ELSE
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ALTERAR(--ESTOQUE
	TABELA VARCHAR(50), 
	COD INT,
	PRODUTO VARCHAR(100), 
	LOJA VARCHAR(10), 
	QUANTIDADE INT) 
RETURNS VOID AS $$
DECLARE
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		IF PRODUTO IS NOT NULL OR LOJA IS NOT NULL OR QUANTIDADE IS NOT NULL THEN
			PERFORM UPDATE_ESTOQUE(COD, PRODUTO, LOJA, QUANTIDADE);
		ELSE 
			RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
		END IF;
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;