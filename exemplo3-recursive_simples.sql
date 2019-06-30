WITH RECURSIVE tabela(i) AS (
    SELECT primeiro_i FROM teste
  UNION ALL
    SELECT i+1 FROM tabela WHERE i < 50
)
SELECT i FROM tabela;

