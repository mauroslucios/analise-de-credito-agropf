-- produto agro
INSERT INTO produto_agro (produto_id, nome_produto) VALUES
(1, 'Soja'),
(2, 'Milho'),
(3, 'Arroz'),
(4, 'Gado');
-- clientes Gerar números de 1 a 500 (sem CTE)
INSERT INTO cliente (
  cliente_id,
  nome,
  tipo_pessoa,
  renda_mensal,
  grupo_familiar_renda,
  negatvado
)
SELECT
  n,
  CONCAT('Cliente Agro ', n),
  'PF',
  300000 + (n * 1500),
  400000 + (n * 2000),
  IF(n % 10 = 0, 1, 0)
FROM (
  SELECT a.n + b.n * 10 + c.n * 100 + 1 AS n
  FROM
    (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
  CROSS JOIN
    (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
  CROSS JOIN
    (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) c
) nums
WHERE n <= 500;
-- Inserir endereços (1:1 com cliente)
INSERT INTO endereco (
  endereco_id,
  cliente_id,
  tipo,
  zona,
  cep
)
SELECT
  cliente_id,
  cliente_id,
  'Fazenda',
  'Rural',
  LPAD(cliente_id, 8, '0')
FROM cliente;
-- produto  Associação cliente ↔ produto (N:N real)
INSERT INTO cliente_produto (
  cliente_produto_id,
  cliente_id,
  produto_id
)
SELECT
  ROW_NUMBER() OVER (ORDER BY c.cliente_id, p.produto_id),
  c.cliente_id,
  p.produto_id
FROM cliente c
JOIN produto_agro p
  ON (c.cliente_id + p.produto_id) % 2 = 0;

-- Se sua versão não suportar ROW_NUMBER(), use esta alternativa:
SET @id := 0;

INSERT INTO cliente_produto (
  cliente_produto_id,
  cliente_id,
  produto_id
)
SELECT
  (@id := @id + 1),
  c.cliente_id,
  p.produto_id
FROM cliente c
JOIN produto_agro p
  ON (c.cliente_id + p.produto_id) % 2 = 0;
-- Limite de crédito coerente com renda
INSERT INTO limite_credito (
  limite_id,
  cliente_id,
  valor_limite_aprovado,
  valor_limite_contratado,
  data_referencia
)
SELECT
  cliente_id,
  cliente_id,
  renda_mensal * 1.2,
  renda_mensal * 0.7,
  NOW()
FROM cliente;
-- Propriedades rurais
INSERT INTO propriedades (
  prop_id,
  cliente_id,
  descricao,
  valor
)
SELECT
  cliente_id,
  cliente_id,
  CONCAT('Propriedade Rural ', cliente_id),
  800000 + (cliente_id * 5000)
FROM cliente;
-- Apontamentos financeiros + socioambientais
INSERT INTO negativacao (
  cliente_id,
  negativacao,
  negativado,
  possui_apontamentos,
  limite_comprometido
)
SELECT
  cliente_id,
  IF(cliente_id % 10 = 0, 1, 0),         -- inadimplência
  IF(cliente_id % 10 = 0, 1, 0),
  IF(cliente_id % 7 = 0 OR cliente_id % 5 = 0, 1, 0), -- ambiental
  IF(cliente_id % 3 = 0, 1, 0)           -- risco alto
FROM cliente;
