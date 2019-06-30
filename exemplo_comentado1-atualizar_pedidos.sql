WITH pedidos_indexados AS (
    SELECT
		p.id_produto,
        p.id_pedido,
		p.qtd_pedido,
        sum(p.qtd_pedido) OVER (PARTITION BY p.id_produto ORDER BY p.id_produto, p.qtd_pedido) AS indice_soma_pedidos, -- Indexando o somatório dos pedidos pendentes de acordo com o id_produto e ordenação da quantia de forma crescente.
        e.disponivel -- Retornando o disponível do estoque para uso futuro
	FROM pedidos p
    JOIN estoque e ON e.id_produto = p.id_produto
	WHERE
		p.cancelado IS FALSE
		AND p.processado IS FALSE
    ORDER BY
        p.id_produto,
        p.qtd_pedido DESC
),
pedidos_pendentes_em_estoque AS (
	SELECT
		pi.id_produto,
        array_agg(pi.id_pedido) AS ids_pedidos, -- agregandos os IDs dos pedidos para uso futuro
		sum(pi.qtd_pedido) AS total -- Somando total por id_produto após agrupamento
	FROM pedidos_indexados pi
	WHERE
		pi.indice_soma_pedidos <= disponivel -- Filtrando apenas pedidos que estão dentro do limite disponível do estoque
    GROUP BY
        pi.id_produto
),
atualizar_pedidos AS ( -- Atualizando a tabela de pedidos de acordo com a validação do estoque
	UPDATE pedidos
	    SET processado = TRUE
	WHERE
		id_pedido IN (SELECT
                        UNNEST(p.ids_pedidos)
                        FROM pedidos_pendentes_em_estoque p)
    RETURNING
        id_pedido, 
        qtd_pedido
),
atualizar_estoque AS ( -- Atualizando a tabela do estoque de acordo com a lista de pedidos validados
	UPDATE estoque
	    SET disponivel = disponivel - p.total
	FROM pedidos_pendentes_em_estoque p
	WHERE
		estoque.id_produto = p.id_produto
	RETURNING
        estoque.id_produto,
        estoque.disponivel AS estoque_remanescente,
        p.total AS saida_realizada
)
SELECT
	*
FROM atualizar_pedidos
WHERE
EXISTS(SELECT * FROM atualizar_estoque); -- Garantindo que os pedidos só serão atualizados após o estoque ser atualizado.

