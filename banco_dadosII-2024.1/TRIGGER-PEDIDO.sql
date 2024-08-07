--------------------------------------------------------------TRIGGER------------------------------------------------------------------
CREATE OR REPLACE FUNCTION NEW_PEDIDO(
	CPF_C VARCHAR(15), 
	NOME_P VARCHAR(50), 
	QUANT_V INT, 
	NOME_PAG VARCHAR(50), 
	CPF_F VARCHAR(15),
	QUANT_PARCELA INT DEFAULT 0)
RETURNS VOID AS $$
DECLARE
	COD_PDD INT; --PEDIDO
	COD_C INT;
	COD_F INT;
	COD_P INT;
	COD_E INT;
	COD_IP INT;
	COD_PAG INT;
	COD_L INT;
	NOME_L VARCHAR;
	QUANT_E INT;
	VALOR_UNIT NUMERIC(8,2);
	VALOR_P NUMERIC(8,2);
	QTDD_P INT;
BEGIN
	SELECT COD INTO COD_C FROM CLIENTE WHERE CPF ILIKE CPF_C;
	SELECT COD INTO COD_F FROM FUNCIONARIO WHERE CPF ILIKE CPF_F;
	SELECT COD INTO COD_P FROM PRODUTO WHERE NOME ILIKE NOME_P;	
	SELECT COD INTO COD_PAG FROM PAGAMENTO WHERE NOME ILIKE NOME_PAG;
	
	SELECT P.COD INTO COD_PDD FROM PEDIDO P JOIN CLIENTE C ON C.COD = P.COD_CLIENTE WHERE P.COD_CLIENTE = COD_C AND PAGO = FALSE;
	SELECT L.COD INTO COD_L FROM LOJA L JOIN FUNCIONARIO F ON F.COD_LOJA = L.COD WHERE F.COD = COD_F;-- JOIN ESTOQUE E ON E.COD_LOJA = L.COD
	SELECT L.NOME INTO NOME_L FROM LOJA L JOIN FUNCIONARIO F ON F.COD_LOJA = L.COD WHERE F.COD = COD_F;--JOIN ESTOQUE E ON E.COD_LOJA = L.COD 
	SELECT COD INTO COD_E FROM ESTOQUE E WHERE COD_PRODUTO = COD_P AND COD_LOJA = COD_L;
	
	SELECT QUANTIDADE INTO QUANT_E FROM ESTOQUE WHERE COD_PRODUTO = COD_P;
	SELECT VALOR_UNITARIO INTO VALOR_UNIT FROM PRODUTO WHERE COD = COD_P;
	SELECT VALOR_PARCELA INTO VALOR_P FROM CREDIARIO C JOIN PEDIDO P ON P.COD = C.COD_PEDIDO WHERE COD_PDD = C.COD_PEDIDO;
	
	--CLIENTE
	IF EXISTS(SELECT * FROM CLIENTE WHERE COD = COD_C) THEN
		--FUNCIONARIO
		IF EXISTS(SELECT * FROM FUNCIONARIO WHERE COD = COD_F) THEN
			-- FUNCIONARIO CARGO
			IF EXISTS(SELECT * FROM FUNCIONARIO F JOIN CARGO C ON C.COD = F.COD_CARGO JOIN LOJA L ON L.COD = F.COD_LOJA WHERE F.COD = COD_F AND C.NOME ILIKE 'Operador de Caixa' OR C.NOME ILIKE 'Vendedor') THEN
				--PRODUTO NA MESMA LOJA QUE O FUNCIONARIO
				IF EXISTS(SELECT * FROM PRODUTO P JOIN ESTOQUE E ON P.COD = E.COD_PRODUTO JOIN FUNCIONARIO F ON F.COD_LOJA = E.COD_LOJA WHERE E.COD_LOJA = F.COD_LOJA AND E.COD_PRODUTO = COD_P AND F.COD = COD_F) THEN
					--PAGAMENTO
					IF EXISTS(SELECT * FROM PAGAMENTO WHERE COD = COD_PAG) THEN
						--PEDIDO
						IF EXISTS(SELECT * FROM PEDIDO WHERE COD = COD_PDD) THEN
							--MESMO CLIENTE MESMO FUNCIONARIO
							IF NOT EXISTS(SELECT * FROM PEDIDO P JOIN CLIENTE C ON C.COD = P.COD_CLIENTE JOIN FUNCIONARIO F ON F.COD = P.COD_FUNCIONARIO WHERE P.COD_FUNCIONARIO = COD_F AND P.COD_CLIENTE = COD_C) THEN
								RAISE EXCEPTION 'O CLIENTE AINDA POSSUI UM OUTRO PEDIDO EM ABERTO.';
							--MESMO PEDIDO PRODUTOS DIFERENTES 
							ELSIF EXISTS(SELECT * FROM ITEM_PEDIDO IP JOIN PEDIDO PDD ON PDD.COD = IP.COD_PEDIDO JOIN ESTOQUE E ON E.COD = IP.COD_ESTOQUE JOIN PRODUTO P ON P.COD = E.COD_PRODUTO WHERE IP.COD_PEDIDO = COD_PDD AND E.COD_PRODUTO = COD_P AND IP.COD_ESTOQUE = E.COD AND E.COD_LOJA = COD_L) THEN 
								--ITEM PEDIDO
								UPDATE ITEM_PEDIDO SET 
									QUANTIDADE = QUANTIDADE + QUANT_V,
									VALOR_TOTAL_ITEM = VALOR_TOTAL_ITEM + (VALOR_UNIT * QUANT_V)
								WHERE COD_PEDIDO = COD_PDD AND COD_ESTOQUE = COD_E;

								RAISE INFO 'PEDIDO ATUALIZADO COM SUCESSO.';
							ELSE 
								INSERT INTO ITEM_PEDIDO(COD_PEDIDO, COD_ESTOQUE, QUANTIDADE, VALOR_TOTAL_ITEM) VALUES(COD_PDD, COD_E, QUANT_V, (QUANT_V * VALOR_UNIT));
								RAISE INFO 'PEDIDO ADICIONADO COM SUCESSO.';	
							END IF;

							--PEDIDO
							UPDATE PEDIDO SET VALOR_TOTAL = VALOR_TOTAL + (VALOR_UNIT * QUANT_V) WHERE COD = COD_PDD;

							--CREDIARIO
							UPDATE CREDIARIO SET
								VALOR_PARCELA = (PDD.VALOR_TOTAL + J.JUROS) / P.QTDD_P
							FROM PEDIDO PDD, 
								(SELECT COUNT(QUANTIDADE_PARCELA) QTDD_P FROM CREDIARIO) P, 
								(SELECT VALOR_JUROS JUROS FROM CREDIARIO) J
							WHERE COD_PEDIDO = COD_PDD;

						ELSE 
							-- PEDIDO
							INSERT INTO PEDIDO(COD_CLIENTE, COD_FUNCIONARIO, COD_PAGAMENTO, VALOR_TOTAL)
							VALUES(COD_C, COD_F, COD_PAG, (VALOR_UNIT * QUANT_V)) RETURNING COD INTO COD_PDD;
				
							-- ITEM_PEDIDO
							INSERT INTO ITEM_PEDIDO(COD_PEDIDO, COD_ESTOQUE, QUANTIDADE, VALOR_TOTAL_ITEM)
							VALUES(COD_PDD, COD_E, QUANT_V, (VALOR_UNIT * QUANT_V));
	
							-- CREDIARIO
							IF NOME_PAG ILIKE 'CREDIÁRIO' THEN
								PERFORM CARNE_CREDIARIO(COD_PDD, QUANT_PARCELA);
								RAISE INFO 'PEDIDO E CREDIÁRIO CRIADOS COM SUCESSO.';
							END IF;		

								RAISE INFO 'PEDIDO CRIADO COM SUCESSO.';
						END IF;
					ELSE 
						RAISE EXCEPTION 'O TIPO DE PAGAMENTO ''%'' NÃO EXISTE.', NOME_PAG;
					END IF;
				ELSE
					RAISE EXCEPTION 'O PRODUTO INFORMADO ''%'' NÃO EXISTE NA LOJA ''%''', NOME_P, NOME_L;
				END IF;
			ELSE
				RAISE EXCEPTION 'O FUNCIONÁRIO ''%'' NÃO PERTENCE AO SETOR.', CPF_F;
			END IF;
		ELSE
			RAISE EXCEPTION 'O FUNCIONÁRIO ''%'' NÃO EXISTE.', CPF_F;
		END IF;
	ELSE
		RAISE EXCEPTION 'O CLIENTE ''%'' NÃO EXISTE.', CPF_C;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION UPDATE_ESTOQUE()
RETURNS TRIGGER AS $$
DECLARE
	QUANT_E INT;
BEGIN
	SELECT QUANTIDADE INTO QUANT_E FROM ESTOQUE WHERE COD = NEW.COD_ESTOQUE;
	
	IF QUANT_E >= NEW.QUANTIDADE THEN
		UPDATE ESTOQUE SET
			QUANTIDADE = QUANTIDADE - NEW.QUANTIDADE
		WHERE COD = NEW.COD_ESTOQUE;
	ELSE
		RAISE EXCEPTION 'QUANTIDADE EM ESTOQUE INSUFICINTE.';
	END IF;
		
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TG_UPDATE_ESTOQUE
BEFORE INSERT OR UPDATE ON ITEM_PEDIDO
FOR EACH ROW
EXECUTE FUNCTION UPDATE_ESTOQUE();

--------------------------------------------------------------------------------------------------------------------------------------------------

SELECT NEW_PEDIDO('123.456.789-10', 'Camiseta Estampada',25, 'Crediário','890.123.456-78',2)
SELECT * FROM FINALIZAR_PEDIDO('123.456.789-10')
SELECT * FROM PAGAR_CARNE('123.456.789-10')

SELECT * FROM PEDIDO --DELETE FROM PEDIDO
SELECT * FROM ITEM_PEDIDO --DELETE FROM ITEM_PEDIDO
SELECT * FROM CREDIARIO --DELETE FROM CREDIARIO
SELECT * FROM CLIENTE
SELECT * FROM FUNCIONARIO
SELECT * FROM LOJA
SELECT * FROM ESTOQUE
SELECT * FROM PRODUTO