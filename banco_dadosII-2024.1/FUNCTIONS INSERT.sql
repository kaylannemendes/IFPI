------------------------------------------FUNCTIONS INSERT----------------------------------------------------

CREATE OR REPLACE FUNCTION ADD_CLIENTE(NOME_C VARCHAR(100), CPF_C VARCHAR(15), CONTATO_C VARCHAR(20), EMAIL_C VARCHAR(50))
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM CLIENTE WHERE NOME ILIKE NOME_C OR CPF_C = CPF) THEN
		INSERT INTO CLIENTE(NOME, CPF, CONTATO, EMAIL) VALUES (NOME_C, CPF_C, CONTATO_C, EMAIL_C);
		RAISE NOTICE 'O CLIENTE %, % FOI CADASTRADO COM SUCESSO.', NOME_C, CPF_C;
	ELSE
		RAISE EXCEPTION 'O CLIENTE JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_CARGO(NOME_C VARCHAR(100), SALARIO_C NUMERIC(8,2), COMISSAO_C NUMERIC(4,2))
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NOME_C) THEN 
		INSERT INTO CARGO (NOME,SALARIO,COMISSAO) VALUES (NOME_C,SALARIO_C,COMISSAO_C);
		RAISE NOTICE 'O CARGO % FOI CADASTRADO COM SUCESSO.', NOME_C;
	ELSE 
		RAISE EXCEPTION 'O CARGO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_LOJA(NOME_L VARCHAR(50), CNPJ_L VARCHAR(18), ENDERECO_L TEXT)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NOME_L OR CNPJ ILIKE CNPJ_L) THEN 
		INSERT INTO LOJA(NOME,CNPJ,ENDERECO) VALUES(NOME_L,CNPJ_L,ENDERECO_L);
		RAISE NOTICE 'A LOJA % FOI CADASTRADA COM SUCESSO', NOME_L;
	ELSE 
		RAISE EXCEPTION 'A LOJA JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_FUNCIONARIO(NOME_CAR VARCHAR(100), NOME_LOJ VARCHAR(50), NOME_F VARCHAR(100), CPF_F VARCHAR(50), CONTATO_F VARCHAR(50), EMAIL_F VARCHAR(50))
RETURNS VOID AS $$
DECLARE 
	COD_CAR INT;
	COD_LOJ INT;
BEGIN
	IF NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE CPF = CPF_F) THEN 
		IF EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NOME_CAR) THEN
			IF EXISTS(SELECT * FROM LOJA WHERE NOME = NOME_LOJ) THEN
				SELECT COD INTO COD_CAR FROM CARGO WHERE NOME ILIKE NOME_CAR;
				SELECT COD INTO COD_LOJ FROM LOJA WHERE NOME ILIKE NOME_LOJ;
	
				INSERT INTO FUNCIONARIO (COD_CARGO, COD_LOJA, NOME, CPF, CONTATO, EMAIL) VALUES(COD_CAR, COD_LOJ, NOME_F, CPF_F, CONTATO_F, EMAIL_F);
				RAISE NOTICE 'O FUNCIONARIO %, % FOI CADASTRADO COM SUCESSO', NOME_F, CPF_F;
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

CREATE OR REPLACE FUNCTION ADD_CATEGORIA(NOME_C VARCHAR(50), DESC_C TEXT)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NOME_C) THEN
		INSERT INTO CATEGORIA(NOME, DESCRICAO) VALUES(NOME_C, DESC_C);
		RAISE NOTICE 'A CATEGORIA % FOI CADASTRADA COM SUCESSO', NOME_C;
	ELSE 
		RAISE EXCEPTION 'A CATEGORIA JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_PRODUTO(NOME_CAT VARCHAR(100), NOME_P VARCHAR(100), VALOR_P NUMERIC(8,2))
RETURNS VOID AS $$
DECLARE
	COD_CAT INT;
BEGIN
	SELECT COD INTO COD_CAT FROM CATEGORIA WHERE NOME ILIKE NOME_CAT;
	
	IF EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NOME_CAT) THEN
		IF NOT EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NOME_P) THEN
			INSERT INTO PRODUTO(COD_CATEGORIA, NOME, VALOR_UNITARIO) VALUES(COD_CAT, NOME_P, VALOR_P);
			RAISE NOTICE 'O PRODUTO % FOI CADASTRADO COM SUCESSO.', NOME_CAT;
		ELSE 
			RAISE EXCEPTION 'O PRODUTO JÁ EXISTE.';
		END IF;
	ELSE 
		RAISE EXCEPTION 'A CATEGORIA NÃO EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_PAGAMENTO(NOME_PAG VARCHAR(50))
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE NOME ILIKE NOME_PAG) THEN
		INSERT INTO PAGAMENTO(NOME) VALUES(NOME_PAG);
		RAISE NOTICE 'O PAGAMENTO % FOI CADASTRADO COM SUCESSO.', NOME_PAG;
	ELSE 
		RAISE EXCEPTION 'O PAGAMENTO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_ESTOQUE(NOME_PROD VARCHAR(100), NOME_LOJ VARCHAR(50), QUANT_P INT)
RETURNS VOID AS $$
DECLARE
	COD_PROD INT;
	COD_LOJ INT;
BEGIN 
	SELECT COD INTO COD_PROD FROM PRODUTO WHERE NOME ILIKE NOME_PROD;
	SELECT COD INTO COD_LOJ FROM LOJA WHERE NOME ILIKE NOME_LOJ;
	
	IF EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NOME_PROD) THEN 
		IF EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NOME_LOJ) THEN
			INSERT INTO ESTOQUE(COD_PRODUTO, COD_LOJA, QUANTIDADE) VALUES(COD_PROD, COD_LOJ, QUANT_P);
		ELSE 
			RAISE EXCEPTION 'A LOJA NÃO EXISTE.';
		END IF;
	ELSE 
		RAISE EXCEPTION 'O PRODUTO NÃO EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

----------------------------------------------------FUNCOES DE CADASTRO---------------------------------------------------------------

CREATE OR REPLACE FUNCTION CADASTRAR(--LOJA
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
		PERFORM ADD_LOJA(NOME, CNPJ, ENDERECO);
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

CREATE OR REPLACE FUNCTION CADASTRAR(--PAGAMENTO
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
		PERFORM ADD_PAGAMENTO(NOME);
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

CREATE OR REPLACE FUNCTION CADASTRAR(--CLIENTE
	TABELA VARCHAR(50), 
	NOME VARCHAR(100), 
	CPF VARCHAR(15), 
	CONTATO VARCHAR(20), 
	EMAIL VARCHAR(50)) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		PERFORM ADD_CLIENTE(NOME, CPF, CONTATO, EMAIL);
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

CREATE OR REPLACE FUNCTION CADASTRAR(--FUNCIONARIO
	TABELA VARCHAR(50), 
	NOME_CAR VARCHAR(50), 
	NOME_LOJ VARCHAR(10), 
	NOME VARCHAR(100), 
	CPF VARCHAR(15), 
	CONTATO VARCHAR(20), 
	EMAIL VARCHAR(50)) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		PERFORM ADD_FUNCIONARIO(NOME_CAR, NOME_LOJ, NOME, CPF, CONTATO, EMAIL);
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

CREATE OR REPLACE FUNCTION CADASTRAR(--CARGO
	TABELA VARCHAR(50), 
	NOME VARCHAR(100), 
	SALARIO NUMERIC(8,2),
	COMISSAO NUMERIC(4,2)) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		PERFORM ADD_CARGO(NOME, SALARIO, COMISSAO);
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

CREATE OR REPLACE FUNCTION CADASTRAR(--CATEGORIA
	TABELA VARCHAR(50), 
	NOME VARCHAR(100), 
	DESCRICAO TEXT) 
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
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		PERFORM ADD_CATEGORIA(NOME, DESCRICAO);
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--PRODUTO
	TABELA VARCHAR(50), 
	CATEGORIA VARCHAR(100), 
	PRODUTO VARCHAR(100), 
	VALOR NUMERIC(8,2)) 
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
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		PERFORM ADD_PRODUTO(CATEGORIA, PRODUTO, VALOR);
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		PERFORM ADD_PRODUTO(CATEGORIA, PRODUTO, VALOR);
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--ESTOQUE
	TABELA VARCHAR(50), 
	PRODUTO VARCHAR(100), 
	LOJA VARCHAR(10), 
	QUANTIDADE INT) 
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
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		PERFORM ADD_ESTOQUE(PRODUTO, LOJA, QUANTIDADE);
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;