/*	
'^[^a-zA-Z0-9]+$' - caracteres especiais
'^[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}$' - formato cpf
'^\([0-9]{2}\) [0-9]{10}' - formato contato
'.*[0-9].*' - numeros dentro de uma string
'^[0-9]' - numeros no comeco da string
*/

--------------------------------------------EXCEÇÕES--------------------------------------------------------------
CREATE OR REPLACE FUNCTION VERIFICAR_ATRIBUTOS_INT(ATRIBUTOS VARCHAR[]) --CHECK_VALUES_INT
RETURNS VOID AS $$ 
DECLARE 
	ATRIBUTO VARCHAR;
BEGIN 
    FOREACH ATRIBUTO IN ARRAY ATRIBUTOS
    LOOP
		IF ATRIBUTO !~ '^[0-9\.\(\)\-\s]+$' THEN
			RAISE EXCEPTION 'ERROR: VALOR INVÁLIDO %.', ATRIBUTO;
		ELSIF ATRIBUTO = '' OR TRIM(ATRIBUTO) = '' THEN
			RAISE EXCEPTION 'ERROR: ATRIBUTO VÁZIO.';
		END IF;
    END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION TRIGGER_VERIFICAR_ATRIBUTOS()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM VERIFICAR_ATRIBUTOS_INT(ARRAY[NEW.CPF, NEW.CONTATO]);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--GATILHOS
CREATE TRIGGER TRIGGER_ADD_ALTER
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW 
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTOS()

CREATE TRIGGER TRIGGER_ADD_ALTER
BEFORE INSERT OR UPDATE ON FUNCIONARIO
FOR EACH ROW 
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTOS()

---------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION VERIFICAR_ATRIBUTOS_VARCHAR(ATRIBUTO VARCHAR) -- CHECK_VALUES_VARCHAR
RETURNS VOID AS $$
BEGIN
	IF ATRIBUTO ~ '.*[0-9].*' OR ATRIBUTO ~ '[0-9]' THEN 
		RAISE EXCEPTION 'ERROR: ATRIBUTO INVÁLIDO %', ATRIBUTO;
	ELSIF ATRIBUTO = '' OR TRIM(ATRIBUTO) = '' THEN
		RAISE EXCEPTION 'ERROR: ATRIBUTO VAZIO.';
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM VERIFICAR_ATRIBUTOS_VARCHAR(NEW.NOME);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--gatilhos
CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON CARGO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON FUNCIONARIO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON PAGAMENTO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON CATEGORIA
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON PRODUTO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();