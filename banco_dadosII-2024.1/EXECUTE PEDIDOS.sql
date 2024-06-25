-------------------------------------------FUNÇÕES DE VENDA-----------------------------------------------------------

CREATE OR REPLACE FUNCTION ADD_PEDIDO(
	CPF_C VARCHAR(15), 
	NOME_P VARCHAR(50), 
	QUANT_V INT, 
	NOME_PAG VARCHAR(50), 
	CPF_F VARCHAR(15))
RETURNS VOID AS $$
DECLARE
	COD_PDD INT; --PEDIDO
	COD_C INT;
	COD_P INT;
	COD_F INT;
	COD_E INT;
	QUANT_E INT;
	VALOR_UNIT NUMERIC(8,2);
	COD_PAG INT;
BEGIN
	SELECT COD INTO COD_C FROM CLIENTE WHERE CPF ILIKE CPF_C;
	SELECT COD INTO COD_F FROM FUNCIONARIO WHERE CPF ILIKE CPF_F;
	SELECT COD INTO COD_P FROM PRODUTO WHERE NOME ILIKE NOME_P;
	SELECT COD INTO COD_PDD FROM PEDIDO WHERE COD_CLIENTE = COD_C AND PAGO = FALSE;
	SELECT COD INTO COD_E FROM ESTOQUE WHERE COD_PRODUTO = COD_P;

	SELECT QUANTIDADE INTO QUANT_E FROM ESTOQUE WHERE COD_PRODUTO = COD_P;
	SELECT VALOR_UNITARIO INTO VALOR_UNIT FROM PRODUTO WHERE COD = COD_P;
	SELECT COD INTO COD_PAG FROM PAGAMENTO WHERE NOME ILIKE NOME_PAG;

	IF EXISTS(SELECT * FROM FUNCIONARIO F JOIN CARGO C ON C.COD = F.COD_CARGO JOIN LOJA L ON L.COD = F.COD_LOJA WHERE F.COD = COD_F AND C.NOME ILIKE 'Caixa' ) THEN
		IF (QUANT_E >= QUANT_V) THEN
			IF EXISTS(SELECT * FROM PEDIDO WHERE COD = COD_PDD) THEN
				IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE COD = COD_PAG) THEN
					RAISE EXCEPTION 'O TIPO DE PAGAMENTO % NÃO EXISTE.', NOME_PAG;
				ELSE
					IF NOT EXISTS(SELECT * FROM PEDIDO P JOIN CLIENTE C ON C.COD = P.COD_CLIENTE) THEN
						RAISE EXCEPTION 'O PEDIDO % JÁ EXISTE, PORÉM OS DADOS NÃO CORRESPONDEM', COD_PDD;
					ELSIF EXISTS(SELECT * FROM ITEM_PEDIDO IP JOIN ESTOQUE E ON E.COD = IP.COD_ESTOQUE JOIN PRODUTO P ON P.COD = E.COD_PRODUTO WHERE IP.COD = COD_PDD AND COD_P = E.COD_PRODUTO) THEN
						UPDATE ITEM_PEDIDO SET 
							QUANTIDADE = QUANTIDADE + QUANT_V,
							VALOR_TOTAL_ITEM = VALOR_TOTAL_ITEM + (VALOR_UNIT * QUANT_V)
						WHERE COD_PEDIDO = COD_PDD AND COD_ESTOQUE = COD_E; 
						RAISE INFO 'PEDIDO ATUALIZADO COM SUCESSO.';
	
					ELSE 
						INSERT INTO ITEM_PEDIDO(COD_PEDIDO, COD_ESTOQUE, QUANTIDADE, VALOR_TOTAL_ITEM) VALUES(COD_PDD, COD_E, QUANT_V, (QUANT_V * VALOR_UNIT));
						RAISE INFO 'PEDIDO ADICIONADO COM SUCESSO.';
	
					END IF;
					UPDATE PEDIDO SET VALOR_TOTAL = VALOR_TOTAL + (VALOR_UNIT * QUANT_V) WHERE COD = COD_PDD;
				END IF;
			ELSE 
				-- PEDIDO
				INSERT INTO PEDIDO(COD_CLIENTE, COD_FUNCIONARIO, COD_PAGAMENTO, VALOR_TOTAL)
				VALUES(COD_C, COD_F, COD_PAG, (VALOR_UNIT * QUANT_V)) RETURNING COD INTO COD_PDD;
	
				-- ITEM_PEDIDO
				INSERT INTO ITEM_PEDIDO(COD_PEDIDO, COD_ESTOQUE, QUANTIDADE, VALOR_TOTAL_ITEM)
				VALUES(COD_PDD, COD_E, QUANT_V, (VALOR_UNIT * QUANT_V));

				RAISE INFO 'PEDIDO CRIADO COM SUCESSO.';
			END IF;
			--DECREMENTA O ESTOQUE
			UPDATE ESTOQUE SET QUANTIDADE = QUANTIDADE - QUANT_V WHERE COD = COD_E;
		ELSE
			RAISE EXCEPTION 'QUANTIDADE EM ESTOQUE INSUFICIENTE.';
		END IF;
	
	ELSIF EXISTS(SELECT * FROM FUNCIONARIO F JOIN CARGO C ON C.COD = F.COD_CARGO JOIN LOJA L ON L.COD = F.COD_LOJA WHERE F.COD = COD_F AND C.NOME NOT ILIKE 'Caixa' ) THEN
		RAISE EXCEPTION 'O FUNCIONÁRIO % NÃO PERTENCE AO SETOR.', CPF_F;
	ELSE
		RAISE EXCEPTION 'O FUNCIONÁRIO % NÃO EXISTE.', CPF_F;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT ADD_PEDIDO('900.800.700-10', 'Calça Jeans Reta', 1, 'Dinheiro', '555.666.777-99')

CREATE OR REPLACE FUNCTION FINALIZAR_PEDIDO(CPF_C VARCHAR(15))
RETURNS TABLE (
	"n°Pedido" VARCHAR, 
	Cliente VARCHAR(100), 
	Produto VARCHAR(100), 
	Valor NUMERIC(8,2), 
	Quantidade INT, 
	Total NUMERIC(8,2), 
	Data VARCHAR(10), 
	Hora VARCHAR(8), 
	Funcionario VARCHAR(100),
	Pago BOOLEAN) AS $$
DECLARE
	COD_C INT;
	COD_P INT;
BEGIN 
	SELECT COD INTO COD_C FROM CLIENTE WHERE CPF ILIKE CPF_C;
	SELECT COD INTO COD_P FROM PEDIDO P WHERE COD_CLIENTE = COD_C AND P.PAGO = FALSE;

	IF EXISTS(SELECT * FROM PEDIDO P WHERE COD = COD_P AND P.PAGO = FALSE) THEN
		UPDATE PEDIDO SET PAGO = TRUE WHERE COD = COD_P;
		RAISE INFO 'PEDIDO FINALIZADO COM SUCESSO.';
		-- RETORNA A NOTA FISCAL DO PEDIDO
		RETURN QUERY
	 		SELECT * FROM NOTA_FISCAL(CPF_C);
	ELSE
		RAISE EXCEPTION 'O CLIENTE % NÃO POSSUI PEDIDO EM ABERTO.', CPF_C;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--DROP FUNCTION FINALIZAR_PEDIDO
SELECT * FROM FINALIZAR_PEDIDO('987.654.321-00')

SELECT * FROM PEDIDO
SELECT * FROM CLIENTE
UPDATE PEDIDO SET PAGO = FALSE
-----------------------------------------------------NOTA FISCAL----------------------------------------------------------------------
CREATE OR REPLACE VIEW PEDIDOS AS 
SELECT 
	PDD.COD Pedido, 
	C.NOME Cliente, 
	P.NOME Produto, 
	F.NOME Funcionario,
	P.VALOR_UNITARIO Valor, 
	IP.QUANTIDADE Quantidade, 
	(P.VALOR_UNITARIO * IP.QUANTIDADE) Total, 
	(TO_CHAR(PDD.DATA_HORA, 'DD-MM-YYYY'))::VARCHAR(10) Data, 
	(TO_CHAR(PDD.DATA_HORA, 'HH24:MI:SS'))::VARCHAR(8) Hora,
	PDD.PAGO PAGO
FROM PEDIDO PDD 
	JOIN ITEM_PEDIDO IP ON IP.COD_PEDIDO = PDD.COD 
	JOIN ESTOQUE E ON E.COD = IP.COD_ESTOQUE 
	JOIN CLIENTE C ON C.COD = PDD.COD_CLIENTE 
	JOIN PRODUTO P ON P.COD = E.COD_PRODUTO 
	JOIN FUNCIONARIO F ON F.COD = PDD.COD_FUNCIONARIO
ORDER BY PDD.COD DESC
	
CREATE OR REPLACE FUNCTION NOTA_FISCAL(CPF_C VARCHAR(15))
RETURNS TABLE ("n°Pedido" VARCHAR, Cliente VARCHAR(100), Produto VARCHAR(100), Valor NUMERIC(8,2), Quantidade INT, Total NUMERIC(8,2), Data VARCHAR(10), Hora VARCHAR(8), Funcionario VARCHAR(100), Pago BOOLEAN) AS $$
DECLARE
	COD_C INT;
	COD_PDD INT;
BEGIN
	SELECT COD INTO COD_C FROM CLIENTE WHERE CPF = CPF_C;
	SELECT P.COD INTO COD_PDD FROM PEDIDO P JOIN CLIENTE C ON C.COD = P.COD_CLIENTE WHERE C.COD = COD_C; --AND P.PAGO = FALSE;

	IF EXISTS(SELECT * FROM CLIENTE WHERE COD = COD_C) THEN
		IF EXISTS(SELECT * FROM PEDIDO WHERE COD = COD_PDD) THEN
			RETURN QUERY
				SELECT 
					(PDD.Pedido)::VARCHAR "n°Pedido", 
					PDD.Cliente, 
					PDD.Produto, 
					PDD.Valor, 
					PDD.Quantidade, 
					PDD.Total, 
					PDD.Data, 
					PDD.Hora,
					PDD.Funcionario,
					PDD.Pago
				FROM PEDIDOS PDD
				WHERE PDD.Pedido = COD_PDD;
		ELSE
			RAISE EXCEPTION 'O CLIENTE % NÃO POSSUI VENDAS EM ABERTO.', CPF_C;
		END IF;
	ELSE
		RAISE EXCEPTION 'O CLIENTE % NÃO EXISTE.', CPF_C;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--DROP FUNCTION NOTA_FISCAL(VARCHAR)
SELECT * FROM NOTA_FISCAL('654.321.987-00')
-----------------------------------------------FUNÇÕES CRUD-------------------------------------------------------------
--ADICIONAR
CREATE OR REPLACE FUNCTION ADICIONAR(--CLIENTE
	TIPO VARCHAR(50), 
	NOME VARCHAR(100), 
	CPF VARCHAR(15), 
	CONTATO VARCHAR(20), 
	EMAIL VARCHAR(50))
RETURNS VOID AS $$
BEGIN
	IF 
END; 
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADICIONAR(--CARGO
	TIPO VARCHAR(50), 
	NOME VARCHAR(100), 
	DESCRICAO VARCHAR(15) OR SALARIO NUMERIC(8,2)
RETURNS VOID AS $$
BEGIN
	IF (TIPO ILIKE 'CLIENTE') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF (TIPO ILIKE 'FUNCIONARIO') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF (TIPO ILIKE 'CARGO') THEN
		PERFORM ADD_CARGO(NOME, DESCRICAO);
	ELSIF (TIPO ILIKE 'LOJA') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF (TIPO ILIKE 'PAGAMENTO') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF (TIPO ILIKE 'PRODUTO') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF (TIPO ILIKE 'ESTOQUE') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF (TIPO ILIKE 'PEDIDO') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF (TIPO ILIKE 'CATEGORIA') THEN
		PERFORM ADD_CARGO(NOME, DESCRICAO);
	ELSIF (TIPO ILIKE 'ITEM_PEDIDO') THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'A TABELA % NÃO FOI ENCONTRADA.', TIPO;
END; 
$$ LANGUAGE PLPGSQL;

SELECT ADICIONAR('CARGO', 'Gestor', NULL,1350.00)


--ALTERAR

--DELETAR