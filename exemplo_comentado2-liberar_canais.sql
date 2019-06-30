WITH dados(id_servico) AS (
	VALUES(1) -- Local onde irei interpolar com minha linguagem
),
ativar_servico AS ( -- Alterando status do serviço
	UPDATE servicos
		SET status = 'ATIVO'
	WHERE
		id_servico = (SELECT d.id_servico FROM dados d) -- Utilizando dado definido no elemento da CTE acima
	RETURNING
        id_servico,
		concat('O serviço ', servicos.nome, ' foi atualizado para o status ', servicos.status) AS ret
),
liberar_canais AS ( -- Liberando lista de canais
	INSERT INTO relacao_canais_ativos_por_servicos
	(id_servico, id_grupo_canais, data_liberacao)
	(SELECT
        id_servico,
        id_grupo_canais,
        NOW()
    FROM servicos_grupos
    WHERE
        id_servico = (SELECT d.id_servico FROM dados d)) -- Reutilizando dado interpolado no outro elemento da CTE
    RETURNING
        id_servico,
        concat('O grupo de canais ', id_grupo_canais, ' foi ativado para o serviço ', id_servico) AS ret
)
SELECT * FROM ativar_servico
UNION
SELECT * FROM liberar_canais;

