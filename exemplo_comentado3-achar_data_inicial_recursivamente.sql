WITH RECURSIVE -- Inicializamos a CTE recursiva
    consultar_data_inicio(id_servico_atual, data_inicio) AS (
    values (5, null::date) -- Trecho de código que será executado na primeira vez, tendo nomes predefinidos acima.
    union all
    SELECT
        id_servico_antigo,
        s.data_inicio
    FROM servicos_trocas st
    JOIN servicos s ON s.id_servico = st.id_servico_antigo
    JOIN consultar_data_inicio ON consultar_data_inicio.id_servico_atual = st.id_servico_novo -- Utilizando dado recursivo
)
select min(data_inicio) AS primeira_data_inicio from consultar_data_inicio;

