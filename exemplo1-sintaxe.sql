WITH carros_reservados AS (
	SELECT
		r.chassis
	FROM reservas r
	WHERE
		r.tipo = ‘carro’
		AND r.data_cancel_reserva IS NULL),

carros_disponiveis AS (
	SELECT
		id_carro,
		chassis,
		nome,
		ano_fabricacao,
		ano_modelo,
		cor,
		valor
	FROM carros
	WHERE
		chassis NOT IN (SELECT cr.chassis FROM carros_reservados cr)
)
SELECT * FROM carros_disponiveis;

