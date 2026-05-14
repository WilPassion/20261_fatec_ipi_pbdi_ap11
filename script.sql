-----------------------------------------------
----------- STORED PROCEDURES
-----------------------------------------------

-- Bloco de Código 2.3.1
-- CREATE OR REPLACE PROCEDURE sp_ola_procedures()
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- 	RAISE NOTICE 'Olá, procedures!!!';
-- END;
-- $$;

-- Bloco de Código 2.3.2
-- CALL  sp_ola_procedures();

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- 2.4 (Stored procedure: usando um parâmetro)
-- CREATE OR REPLACE PROCEDURE sp_ola_usuario(nome VARCHAR (200))
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--  	RAISE NOTICE 'Olá, %', nome;
-- END;
-- $$

-- -- executando
-- CALL sp_ola_usuario('Pedro');

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.6.1 - IN promete calcular o maior valor entre 
-- dois parâmetros recebidos.
-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
--     IN valor1 INT,
--     IN valor2 INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF valor1 > valor2 THEN
--         RAISE NOTICE 'O maior valor é %', valor1;
--     ELSE
--         RAISE NOTICE 'O maior valor é %', valor2;
--     END IF;
-- END;
-- $$;

-- -- executando
-- CALL sp_acha_maior(5, 10);

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.7.1 Parâmetros OUT
-- DROP PROCEDURE IF EXISTS sp_acha_maior;
-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
-- 	OUT resultado INT,
-- 	IN valor1 INT,
-- 	IN valor2 INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN 
-- 	CASE 
-- 		WHEN valor1 > valor2 THEN
-- 			resultado := valor1;
-- 		ELSE 
-- 			resultado := valor2;
-- 	END CASE;
-- END;
-- $$

-- -- executando
-- DO $$
-- DECLARE
-- 	resultado INT;
-- BEGIN
-- 	CALL sp_acha_maior(resultado, 50, 10);
-- 	RAISE NOTICE 'O maior valor é %', resultado;
-- END;
-- $$

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- 2.8 (Stored procedure: Parâmetros INOUT)
-- DROP PROCEDURE IF EXISTS sp_acha_maior;
-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
--  	INOUT valor1 INT,
--  	IN valor2 INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN
--  	IF valor2 > valor1 THEN
--  		valor1 := valor2;
--  	ELSE
--  		valor2 := valor1;
--  	END IF;
-- END;
-- $$

-- -- executando
-- DO $$
-- DECLARE
--  	valor1 INT := 2;
--  	valor2 INT := 3;
-- BEGIN
-- 	CALL sp_acha_maior(valor1, valor2);
-- 	RAISE NOTICE '% é o maior', valor1;
-- END;
-- $$

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.9.1
-- -- VARIADIC permite passar vários valores |
-- -- valores INT[] significa que esses valores 
-- -- serão tratados como um array de inteiros
-- CREATE OR REPLACE PROCEDURE sp_calcula_media(VARIADIC valores INT[])
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     media NUMERIC(10, 2) := 0; 
--     -- soma acumulada começando por 0

--     valor INT; 
--     -- vai guardar um valor por vez no FOREACH
--     -- CALL sp_calcula_media(1, 8, 10)

-- BEGIN
--     FOREACH valor IN ARRAY valores LOOP
        
--         -- Soma o valor atual na variável media
        
--         -- media = 0 + 1 = 1
--         -- media = 1 + 8 = 9
--         -- media = 9 + 10 = 19
        
--         media := media + valor;

--     END LOOP; 

--     -- array_length(valores, 1) --> uma dimensão - array
--     -- retorna a quantidade de elementos do array
--     -- neste caso: 3

--     -- cálculo:
--     -- (1 + 8 + 10) / 3
--     -- 19 / 3
--     -- 6.33

--     RAISE NOTICE 'A média é %', media / array_length(valores, 1);

-- END;
-- $$;

-- -- executando com 3 parâmetros
-- -- ARRAY[1, 8, 10]

-- CALL sp_calcula_media(1, 8, 10);

-- -- outras qtdades parâmetros
-- CALL sp_calcula_media(1);
-- CALL sp_calcula_media(1, 5); 
-- CALL sp_calcula_media(10, 5, 2, 1);

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- 2.10 (Stored procedures: implementação de um restaurante) 
-- Bloco de Código 2.10.1
-- CREATE TABLE tb_tipo(
-- 	cod_tipo SERIAL PRIMARY KEY,
-- 	descricao VARCHAR(150) NOT NULL
-- );

-- INSERT INTO tb_tipo (descricao)
-- VALUES
-- ('Bedida'),
-- ('Comida');

-- ------

-- CREATE TABLE tb_cliente(
-- 	cod_cliente SERIAL PRIMARY KEY,
-- 	nome VARCHAR(150) NOT NULL
-- );

-- -----------

-- CREATE TABLE tb_item(
-- 	cod_item SERIAL PRIMARY KEY,
-- 	descricao VARCHAR(150) NOT NULL,
-- 	valor NUMERIC(10, 2) NOT NULL,
-- 	cod_tipo INT NOT NULL, 
-- 	CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES
-- 	tb_tipo(cod_tipo)
-- );

-- INSERT INTO tb_item
-- (descricao, valor, cod_tipo)
-- VALUES
-- ('Refrigerante', 10, 1),
-- ('Suco', 8, 1),
-- ('Hamburguer', 55, 2),
-- ('Batata Frita', 15, 2);

-- CREATE TABLE tb_pedido(
-- 	cod_pedido SERIAL PRIMARY KEY,
-- 	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- 	data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- 	status VARCHAR DEFAULT 'aberto',
-- 	cod_cliente INT NOT NULL,
-- 	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES tb_cliente(cod_cliente)
-- );

-- CREATE TABLE tb_item_pedido(
-- 	--surrogate key
-- 	cod_item_pedido SERIAL PRIMARY KEY,
-- 	cod_item INT,
-- 	cod_pedido INT,
-- 	CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES tb_item (cod_item),
-- 	CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES tb_pedido (cod_pedido)
-- );

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.10.2 - procedimento que faz o
-- cadastro de clientes.
-- CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente(
-- 	IN nome VARCHAR(150),
-- 	IN codigo INT DEFAULT NULL -- se for null, permite inserir manualmente
-- ) LANGUAGE plpgsql
-- AS $$		
-- BEGIN
-- 	--se o código for NULL, cadastrar apenas nome, gerando automático
-- 	IF codigo IS NULL THEN
-- 		INSERT INTO tb_cliente(nome) VALUES(nome);
-- 	ELSE
-- 	-- caso contrário, cadastrar com código recebido	
-- 		INSERT INTO tb_clinte(cod_cliente, nome) VALUES (codigo, nome);
-- 	END IF;
-- END;
-- $$

-- CALL sp_cadastrar_cliente ('João da Silva');
-- CALL sp_cadastrar_cliente ('Maria Santos');
-- SELECT * FROM tb_cliente;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.10.3 - faz a criação de um pedido para um cliente(AINDA SEM ITEM). A ideia 
-- é simular a entrada do cliente no restaurante, momento em que ele pega a sua comanda.

-- -- criar um pedido - cliente entra e pega a comanda
-- CREATE OR REPLACE PROCEDURE sp_criar_pedido(

--     OUT cod_pedido INT, -- Procedure cria pedido -> cod_pedido sai/devolve
--     IN cod_cliente INT -- cod_cliente entra

-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN

--     INSERT INTO tb_pedido (cod_cliente) VALUES (cod_cliente);
-- 	-- obtém o último valor gerado por SERIAL
--     SELECT LASTVAL() INTO cod_pedido;

-- END;
-- $$;

-- ----

-- DO
-- $$
-- DECLARE

-- --para guardar o código de pedido gerado
-- cod_pedido INT;

-- -- o código do cliente que vai fazer o pedido
-- cod_cliente INT;

-- BEGIN

-- -- pega o código da pessoa cujo nome é "João da Silva"
-- SELECT c.cod_cliente 
-- FROM tb_cliente c 
-- WHERE nome LIKE 'João da Silva'
-- INTO cod_cliente;

-- --cria o pedido
-- CALL sp_criar_pedido(cod_pedido, cod_cliente);

-- RAISE NOTICE 'Código do pedido recém criado: %', cod_pedido;

-- END;
-- $$;

-- SELECT * FROM tb_pedido;

-- Bloco de Código 2.10.4 - Adição de item a um pedido - deve ser chamado 
-- quando um cliente desejar um novo item


-- -- adicionar um item a um pedido
-- DROP PROCEDURE IF EXISTS sp_adicionar_item_a_pedido;
-- CREATE OR REPLACE PROCEDURE sp_adicionar_item_a_pedido(

--     IN p_cod_item INT,
--     IN p_cod_pedido INT

-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN

--     --insere novo item
--     INSERT INTO tb_item_pedido (
--         cod_item,
--         cod_pedido
--     )
--     VALUES (
--         p_cod_item,
--         p_cod_pedido
--     );

--     --atualiza data de modificação do pedido
--     UPDATE tb_pedido
--     SET data_modificacao = CURRENT_TIMESTAMP
--     WHERE cod_pedido = p_cod_pedido;

-- END;
-- $$;

-- CALL sp_adicionar_item_a_pedido(1, 1);
-- SELECT * FROM tb_item_pedido;
-- SELECT * FROM tb_pedido;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.10.5 -  somatório dos valores de seus itens

-- --calcular valor total de um pedido
-- DROP PROCEDURE IF EXISTS sp_calcular_valor_de_um_pedido;

-- CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido(

--     IN p_cod_pedido INT,
--     OUT valor_total INT

-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN

--     SELECT SUM(i.valor)
--     FROM tb_pedido p

--     INNER JOIN tb_item_pedido ip
--         ON p.cod_pedido = ip.cod_pedido

--     INNER JOIN tb_item i
--         ON i.cod_item = ip.cod_item

--     WHERE p.cod_pedido = p_cod_pedido
--     INTO valor_total;

-- END;
-- $$;


-- DO $$
-- DECLARE

--     valor_total INT;

-- BEGIN

--     CALL sp_calcular_valor_de_um_pedido(1, valor_total);

--     RAISE NOTICE 'Total do pedido %: R$%', 1, valor_total;

-- END;
-- $$;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.10.6 -  fecha um pedido, desde que o valor entregue
-- pelo cliente seja suficiente para pagar a conta.

-- CREATE OR REPLACE PROCEDURE sp_fechar_pedido(

--     IN valor_a_pagar INT,
--     IN p_cod_pedido INT

-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE

--     valor_total INT;

-- BEGIN

--     --vamos verificar se o valor_a_pagar é suficiente
--     CALL sp_calcular_valor_de_um_pedido(
--         p_cod_pedido,
--         valor_total
--     );

--     IF valor_a_pagar < valor_total THEN

--         RAISE 'R$% insuficiente para pagar a conta de R$%',
--             valor_a_pagar,
--             valor_total;

--     ELSE

--         UPDATE tb_pedido
--         SET
--             data_modificacao = CURRENT_TIMESTAMP,
--             status = 'fechado'

--         WHERE cod_pedido = p_cod_pedido;

--     END IF;

-- END;
-- $$;


-- DO $$
-- BEGIN

--     CALL sp_fechar_pedido(200, 1);

-- END;
-- $$;


-- SELECT * FROM tb_pedido;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.10.7 - Cálculo do troco

-- CREATE OR REPLACE PROCEDURE sp_calcular_troco(

--     OUT troco INT,
--     IN valor_a_pagar INT,
--     IN valor_total INT

-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN

--     troco := valor_a_pagar - valor_total;

-- END;
-- $$;


-- DO
-- $$
-- DECLARE

--     troco INT;
--     valor_total INT;
--     valor_a_pagar INT := 100;

-- BEGIN

--     CALL sp_calcular_valor_de_um_pedido(
--         1,
--         valor_total
--     );

--     CALL sp_calcular_troco(
--         troco,
--         valor_a_pagar,
--         valor_total
--     );

--     RAISE NOTICE
--         'A conta foi de R$% e você pagou %, portanto, seu troco é de R$%.',
--         valor_total,
--         valor_a_pagar,
--         troco;

-- END;
-- $$;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Bloco de Código 2.10.8 -  procedimento que calcula as notas a serem utilizadas
-- para compor um determinado valor de troco

-- CREATE OR REPLACE PROCEDURE sp_obter_notas_para_compor_o_troco(

--     OUT resultado VARCHAR(500),
--     IN troco INT

-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE

--     notas200 INT := 0;
--     notas100 INT := 0;
--     notas50 INT := 0;
--     notas20 INT := 0;
--     notas10 INT := 0;
--     notas5 INT := 0;
--     notas2 INT := 0;
--     moedas1 INT := 0;

-- BEGIN

--     notas200 := troco / 200;

--     notas100 := troco % 200 / 100;

--     notas50 := troco % 200 % 100 / 50;

--     notas20 := troco % 200 % 100 % 50 / 20;

--     notas10 := troco % 200 % 100 % 50 % 20 / 10;

--     notas5 := troco % 200 % 100 % 50 % 20 % 10 / 5;

--     notas2 := troco % 200 % 100 % 50 % 20 % 10 % 5 / 2;

--     moedas1 := troco % 200 % 100 % 50 % 20 % 10 % 5 % 2;

--     resultado := concat(

--         -- E é de escape. Para que \n tenha sentido
--         -- || é um operador de concatenação

--         'Notas de 200: ',
--         notas200 || E'\n',

--         'Notas de 100: ',
--         notas100 || E'\n',

--         'Notas de 50: ',
--         notas50 || E'\n',

--         'Notas de 20: ',
--         notas20 || E'\n',

--         'Notas de 10: ',
--         notas10 || E'\n',

--         'Notas de 5: ',
--         notas5 || E'\n',

--         'Notas de 2: ',
--         notas2 || E'\n',

--         'Moedas de 1: ',
--         moedas1 || E'\n'

--     );

-- END;
-- $$;


-- DO
-- $$
-- DECLARE

--     resultado VARCHAR(500);

--     troco INT := 43;

-- BEGIN

--     CALL sp_obter_notas_para_compor_o_troco(
--         resultado,
--         troco
--     );

--     RAISE NOTICE '%', resultado;

-- END;
-- $$;

-----------------------------------------------
-------------------- NOTAS
-----------------------------------------------

-- IN:
-- Utilizado para receber valores de entrada enviados pelo cliente.
-- O procedimento consegue utilizar o valor no processamento,
-- mas não pode alterar o parâmetro original.
-- Casos de uso:
-- - receber nome, idade, preço, CPF, quantidade etc.
-- - filtros de consultas
-- - valores para cálculos
--
-- Exemplo:
-- CALL sp_calcula_idade(2000);


-- OUT:
-- Utilizado para devolver valores ao cliente.
-- O parâmetro funciona como uma saída do procedimento.
-- Deve receber um valor antes do término da procedure.
-- Casos de uso:
-- - retornar resultados de cálculos
-- - retornar médias, totais, mensagens ou status
-- - informar o maior/menor valor
--
-- Exemplo:
-- CALL sp_acha_maior(NULL, 10, 20);


-- INOUT:
-- Utilizado quando o parâmetro entra com um valor
-- e sai com esse mesmo valor alterado.
-- Funciona como entrada e saída ao mesmo tempo.
-- Casos de uso:
-- - incrementar contadores
-- - atualizar saldo
-- - modificar pontuação
-- - alterar valores acumulados
--
-- Exemplo:
-- CALL sp_incrementa_valor(10);

-- VARIADIC:
-- Um parâmetro VARIADIC permite que uma procedure ou função
-- receba vários valores em um único parâmetro.
--
-- Esses valores são armazenados em uma coleção.
--
-- Coleção:
-- É um conjunto de valores agrupados em uma única estrutura.
-- Em PL/pgSQL, normalmente utilizamos arrays como coleção.
--
-- Exemplo de coleção:
-- ARRAY[10, 20, 30, 40]
--
-- Nesse caso:
-- - a coleção possui 4 elementos
-- - cada elemento é um valor inteiro
--
-- O VARIADIC transforma automaticamente os valores enviados
-- pelo cliente em um array.
--
-- Sem VARIADIC:
-- Precisaríamos criar vários parâmetros:
-- (n1, n2, n3, n4...)
--
-- Com VARIADIC:
-- Podemos receber vários valores dinamicamente.
--
-- Casos de uso:
-- - somar vários números
-- - calcular média de vários valores
-- - trabalhar com listas de IDs
-- - receber vários nomes ou categorias
-- - evitar criar muitos parâmetros fixos
--
-- Exemplo de declaração:
--
-- CREATE PROCEDURE exemplo(VARIADIC numeros INT[])
--
-- Exemplo de chamada:
--
-- CALL exemplo(10, 20, 30, 40);
--
-- O PostgreSQL transforma automaticamente em:
--
-- ARRAY[10, 20, 30, 40]
--
-- Exemplo prático:
-- Somar vários números enviados pelo cliente.
--
-- CREATE OR REPLACE PROCEDURE sp_soma(
--     VARIADIC numeros INT[]
-- )
--
-- O procedimento pode percorrer a coleção usando FOREACH:
--
-- FOREACH numero IN ARRAY numeros LOOP
--     soma := soma + numero;
-- END LOOP;