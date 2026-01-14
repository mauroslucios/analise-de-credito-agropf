-- validação da Regra de Elegibilidade (≥ R$ 500.000)
-- Regra de negócio Um cliente Agro PF é elegível a crédito se:
-- tipo_pessoa = 'PF'
-- grupo_familiar_renda >= 500000

-- Query de validação (quantitativo)
SELECT
  COUNT(*) AS total_clientes_elegiveis
FROM cliente
WHERE tipo_pessoa = 'PF'
  AND grupo_familiar_renda >= 500000;

-- Query analítica (transparência)
SELECT
  cliente_id,
  nome,
  renda_mensal,
  grupo_familiar_renda
FROM cliente
WHERE tipo_pessoa = 'PF'
  AND grupo_familiar_renda >= 500000
ORDER BY grupo_familiar_renda DESC;

-- Query de decisão (produção real)
SELECT
  c.cliente_id,
  c.nome,
  c.grupo_familiar_renda,
  lc.valor_limite_aprovado,
  lc.valor_limite_contratado,
  (lc.valor_limite_aprovado - lc.valor_limite_contratado) AS limite_disponivel,

  CASE
    WHEN c.grupo_familiar_renda < 500000 THEN 'BLOQUEADO_RENDA'
    WHEN n.negativado = 1 THEN 'BLOQUEADO_NEGATIVACAO'
    WHEN n.possui_apontamentos = 1 THEN 'BLOQUEADO_SOCIOAMBIENTAL'
    WHEN n.limite_comprometido = 1 THEN 'BLOQUEADO_RISCO'
    WHEN (lc.valor_limite_aprovado - lc.valor_limite_contratado) <= 0 THEN 'SEM_LIMITE'
    ELSE 'LIBERADO'
  END AS decisao_credito

FROM cliente c
JOIN limite_credito lc ON lc.cliente_id = c.cliente_id
LEFT JOIN negativacao n ON n.cliente_id = c.cliente_id
WHERE c.tipo_pessoa = 'PF';