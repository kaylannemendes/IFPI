---------------------------------COMISSAO: VENDEDOR E OPERADOR------------------------------------------------
CREATE TABLE COMISSAO_FUNCIONARIO (
    COD SERIAL PRIMARY KEY,
    COD_FUNCIONARIO INT NOT NULL REFERENCES FUNCIONARIO(COD) 
		ON DELETE CASCADE 
		ON UPDATE CASCADE,
    COD_PEDIDO INT REFERENCES PEDIDO(COD) 
		ON DELETE CASCADE 
		ON UPDATE CASCADE,
    COMISSAO NUMERIC(8,2) NOT NULL,
    DATA_COMISSAO TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION CALCULAR_COMISSAO_VENDEDOR_OPERADOR(COD_FUNCIONARIO INT, COD_PEDIDO INT)
RETURNS VOID AS $$
DECLARE
    COMISSAO NUMERIC(8,2);
    VALOR_VENDA NUMERIC(8,2);
    CARGO_FUNCIONARIO VARCHAR(50);
BEGIN
    -- Obter o cargo do funcionário
    SELECT C.NOME INTO CARGO_FUNCIONARIO
    FROM FUNCIONARIO F
    JOIN CARGO C ON F.COD_CARGO = C.COD
    WHERE F.COD = COD_FUNCIONARIO;
    
    -- Obter o valor total da venda no pedido
    SELECT P.VALOR_TOTAL INTO VALOR_VENDA
    FROM PEDIDO P
    WHERE P.COD = COD_PEDIDO;

    -- Calcular a comissão de acordo com o cargo
    IF CARGO_FUNCIONARIO ILIKE 'Vendedor' THEN
        COMISSAO := VALOR_VENDA * 0.10;
    ELSIF CARGO_FUNCIONARIO ILIKE 'Operador de Caixa' THEN
        COMISSAO := VALOR_VENDA * 0.5;
    ELSE
        -- Caso o cargo não seja Vendedor ou Operador de Caixa, não calcular comissão
        RAISE NOTICE 'Comissão não aplicável para o cargo %', CARGO_FUNCIONARIO;
        RETURN;
    END IF;

    -- Registrar a comissão na tabela
    INSERT INTO COMISSAO_FUNCIONARIO (COD_FUNCIONARIO, COD_PEDIDO, COMISSAO)
    VALUES (COD_FUNCIONARIO, COD_PEDIDO, COMISSAO);

    RAISE NOTICE 'Comissão de % registrada para o % % no pedido %', COMISSAO, CARGO_FUNCIONARIO, COD_FUNCIONARIO, COD_PEDIDO;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION REGISTRAR_COMISSAO_FUNCIONARIO() --funcao trigger que registra a comissao
RETURNS TRIGGER AS $$
BEGIN
	 PERFORM CALCULAR_COMISSAO_VENDEDOR_OPERADOR(NEW.COD_FUNCIONARIO, NEW.COD);
	 RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TG_REGISTRAR_COMISSAO_FUNCIONARIO --trigger que dispara toda vez que um pedido é pago
AFTER UPDATE OF PAGO ON PEDIDO
FOR EACH ROW
WHEN (NEW.PAGO = TRUE)
EXECUTE FUNCTION REGISTRAR_COMISSAO_FUNCIONARIO();

-----------------------------------------------METAS LOJA-----------------------------------------------------------

CREATE TABLE META_LOJA (--Insert Into meta_loja(cod_loja,meta_total ) values (1, 1000)
  	COD_META_LOJA SERIAL PRIMARY KEY,
    COD_LOJA INT REFERENCES LOJA(COD) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    META_TOTAL NUMERIC(8,2) DEFAULT 100000.00 NOT NULL,
    VALOR_ACUMULADO NUMERIC(8,2) DEFAULT 0.00 NOT NULL
);

CREATE OR REPLACE FUNCTION ATUALIZAR_META_LOJA()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza o valor acumulado na tabela META_LOJA
    UPDATE META_LOJA SET 
		VALOR_ACUMULADO = VALOR_ACUMULADO + (SELECT VALOR_TOTAL FROM PEDIDO WHERE COD = NEW.COD)
    WHERE COD_LOJA = 
		(SELECT COD_LOJA FROM funcionario WHERE COD = NEW.COD_FUNCIONARIO);

    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_ATUALIZAR_META_LOJA
AFTER UPDATE ON PEDIDO
FOR EACH ROW
WHEN (NEW.PAGO = TRUE)
EXECUTE FUNCTION ATUALIZAR_META_LOJA();

------------------------------------------COMISSAO GERENTE-------------------------------------------------------

CREATE OR REPLACE FUNCTION CALCULAR_COMISSAO_GERENTE(COD_LOJA INT)
RETURNS VOID AS $$
DECLARE
    META NUMERIC(8,2);
    VALOR_ACUMULADO NUMERIC(8,2);
    COMISSAO_GERENTE NUMERIC(8,2);
    COD_GERENTE INT;
BEGIN
    -- Obter a meta e o valor acumulado da loja, referenciando as colunas com o nome da tabela
    SELECT ml.META_TOTAL, ml.VALOR_ACUMULADO INTO META, VALOR_ACUMULADO
    FROM META_LOJA ml
	WHERE ml.COD_LOJA = COD_LOJA;
    --WHERE ml.COD_LOJA = CALCULAR_COMISSAO_GERENTE.COD_LOJA; -- Qualificando com o nome completo da função
    
    -- Verificar se o gerente está atribuído à loja, qualificando o COD_LOJA
    SELECT f.COD INTO COD_GERENTE
    FROM FUNCIONARIO f
    JOIN CARGO c ON f.COD_CARGO = c.COD
    --WHERE f.COD_LOJA = CALCULAR_COMISSAO_GERENTE.COD_LOJA -- Qualificando novamente com o nome completo da função
	WHERE f.COD_LOJA = COD_LOJA
    AND c.NOME ILIKE 'Gerente';

    IF VALOR_ACUMULADO >= META THEN
        -- Comissão completa (15%)
        COMISSAO_GERENTE := VALOR_ACUMULADO * 0.15;
    ELSIF VALOR_ACUMULADO BETWEEN (META * 0.45) AND (META * 0.70) THEN
        -- Metade da comissão (7.5%)
        COMISSAO_GERENTE := VALOR_ACUMULADO * 0.075;
    ELSE
        -- Sem comissão
        COMISSAO_GERENTE := 0;
    END IF;

    -- Inserir a comissão na tabela COMISSAO_FUNCIONARIO, se houver comissão
    IF COMISSAO_GERENTE > 0 THEN
        INSERT INTO COMISSAO_FUNCIONARIO (COD_FUNCIONARIO, COMISSAO, DATA_COMISSAO)
        VALUES (COD_GERENTE, COMISSAO_GERENTE, CURRENT_TIMESTAMP);
        
        RAISE NOTICE 'Comissão de % registrada para o gerente da loja %', COMISSAO_GERENTE, CALCULAR_COMISSAO_GERENTE.COD_LOJA;
    ELSE
        RAISE NOTICE 'O gerente da loja % não atingiu a meta e não receberá comissão.', CALCULAR_COMISSAO_GERENTE.COD_LOJA;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION VERIFICAR_META_LOJA() 
RETURNS TRIGGER AS $$--funcao que verifica se o valor de venda acumulado na loja x alcançou a meta batida,
DECLARE 			--se sim, calcula a comissao do gerente sobre o valor acumulado
	META NUMERIC(8,2);
	VALOR_ACUMULADO NUMERIC(8,2);
BEGIN
	SELECT META_TOTAL, VALOR_ACUMULADO INTO META, VALOR_ACUMULADO FROM META_LOJA WHERE COD_LOJA = NEW.COD_LOJA;

	IF NEW.VALOR_ACUMULADO >= NEW.META_TOTAL THEN
		PERFORM CALCULAR_COMISSAO_GERENTE(NEW.COD_LOJA);
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_VERIFICAR_META_LOJA --trigger dispara toda vez que a meta é batida
AFTER UPDATE ON META_LOJA
FOR EACH ROW 
WHEN (NEW.VALOR_ACUMULADO >= OLD.META_TOTAL)
EXECUTE FUNCTION VERIFICAR_META_LOJA();