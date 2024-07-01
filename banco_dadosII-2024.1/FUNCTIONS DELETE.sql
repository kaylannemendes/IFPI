------------------------------------------------FUNCTIONS DELETE-----------------------------------------------------
CREATE OR REPLACE FUNCTION DELETE_CLIENTE(COD_C INT)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM CLIENTE WHERE COD = COD_C ) THEN
		RAISE EXCEPTION 'O CLIENTE DE CÓDIGO % NÃO EXISTE.', COD_C;
	ELSE
		BEGIN 
			DELETE FROM CLIENTE WHERE COD = COD_C;
			RAISE INFO 'CLIENTE DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR O CLIENTE DE CÓDIGO %. CHAVE ESTRANGEIRA VIOLADA.', COD_C;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DELETE_CARGO(COD_CAR INT)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM CARGO WHERE COD = COD_CAR ) THEN
		RAISE EXCEPTION 'O CARGO DE CÓDIGO % NÃO EXISTE.', COD_CAR;
	ELSE
		BEGIN 
			DELETE FROM CARGO WHERE COD = COD_CAR;
			RAISE INFO 'CARGO DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				--RAISE EXCEPTION ' PORQUE ELE ESTÁ ASSOCIADO A OUTRA TABELA.', COD_C;
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR O CARGO DE CÓDIGO %. CHAVE ESTRANGEIRA VIOLADA.', COD_CAR;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DELETE_LOJA(COD_L INT)
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM LOJA WHERE COD = COD_L ) THEN
		RAISE EXCEPTION 'A LOJA DE CÓDIGO % NÃO EXISTE.', COD_L;
	ELSE
		BEGIN 
			DELETE FROM LOJA WHERE COD = COD_L;
			RAISE INFO 'LOJA DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				--RAISE EXCEPTION ' O CLIENTE DE CÓDIGO % PORQUE ELE ESTÁ ASSOCIADO A OUTRA TABELA.', COD_C;
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR A LOJA DE CÓDIGO %. CHAVE ESTRANGEIRA VIOLADA.', COD_L;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DELETE_FUNCIONARIO(COD_F INT)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE COD = COD_F ) THEN
		RAISE EXCEPTION 'O FUNCIONARIO DE CÓDIGO % NÃO EXISTE.', COD_F;
	ELSE
		BEGIN 
			DELETE FROM FUNCIONARIO WHERE COD = COD_F;
			RAISE INFO 'FUNCIONARIO DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR O FUNCIONARIO DE CÓDIGO %. CHAVE ESTRANGEIRA VIOLADA.', COD_F;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DELETE_PAGAMENTO(COD_PAG INT)
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE COD = COD_PAG ) THEN
		RAISE EXCEPTION 'O PAGAMENTO DE CÓDIGO % NÃO EXISTE.', COD_PAG;
	ELSE
		BEGIN 
			DELETE FROM PAGAMENTO WHERE COD = COD_PAG;
			RAISE INFO 'PAGAMENTO DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR O PAGAMENTO DE CÓDIGO %. CHAVE ESTRANGEIRA VIOLADA.', COD_PAG;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DELETE_CATEGORIA(COD_CAT INT)
RETURNS VOID AS $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM CATEGORIA WHERE COD = COD_CAT ) THEN
		RAISE EXCEPTION 'A CATEGORIA DE CÓDIGO % NÃO EXISTE.', COD_CAT;
	ELSE
		BEGIN 
			DELETE FROM CATEGORIA WHERE COD = COD_CAT;
			RAISE INFO 'CATEGORIA DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR A CATEGORIA DE CÓDIGO %. CHAVE ESTRANGEIRA VIOLADA.', COD_CAT;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DELETE_PRODUTO(COD_P INT)
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM PRODUTO WHERE COD = COD_P ) THEN
		RAISE EXCEPTION 'O PRODUTO DE CÓDIGO % NÃO EXISTE.', COD_P;
	ELSE
		BEGIN 
			DELETE FROM PRODUTO WHERE COD = COD_P;
			RAISE INFO 'PRODUTO DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR O PRODUTO DE CÓDIGO  %. CHAVE ESTRANGEIRA VIOLADA.', COD_P;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DELETE_ESTOQUE(COD_E INT)
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM ESTOQUE WHERE COD = COD_E ) THEN
		RAISE EXCEPTION 'O ESTOQUE DE CÓDIGO % NÃO EXISTE.', COD_E;
	ELSE
		BEGIN 
			DELETE FROM ESTOQUE WHERE COD = COD_E;
			RAISE INFO 'ESTOQUE DELETADO COM SUCESSO.';
		EXCEPTION
			WHEN foreign_key_violation THEN
				RAISE EXCEPTION 'NÃO FOI POSSÍVEL EXCLUIR O ESTOQUE DE CÓDIGO %. CHAVE ESTRANGEIRA VIOLADA.', COD_E;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

----------------------------------------------FUNCAO DELETAR--------------------------------------------------

CREATE OR REPLACE FUNCTION DELETAR(TABELA VARCHAR(50), COD INT)
RETURNS VOID AS $$
BEGIN
	IF TABELA ILIKE 'CLIENTE' THEN
		PERFORM DELETE_CLIENTE(COD);
	ELSIF TABELA ILIKE 'CARGO' THEN
		PERFORM DELETE_CARGO(COD);
	ELSIF TABELA ILIKE 'LOJA' THEN
		PERFORM DELETE_LOJA(COD);
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		PERFORM DELETE_FUNCIONARIO(COD);
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		PERFORM DELETE_PAGAMENTO(COD);
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		PERFORM DELETE_CATEGORIA(COD);
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		PERFORM DELETE_PRODUTO(COD);
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		PERFORM DELETE_ESTOQUE(COD);
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$  LANGUAGE PLPGSQL;