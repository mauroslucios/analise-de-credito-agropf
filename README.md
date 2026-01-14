# ETL – Decisão de Crédito Agro

## Visão Geral
Este projeto implementa um **pipeline ETL completo em PySpark** para análise e decisão de crédito no contexto agro. O fluxo extrai dados de um banco **MySQL**, aplica **regras de negócio de crédito**, e persiste os resultados em um **Data Lake S3 (LocalStack)**, já preparado para consumo analítico (Athena / Spark SQL / BI).

O ETL segue boas práticas de engenharia de dados, com **logging estruturado**, separação clara entre **Extract, Transform e Load**, versionamento por data e persistência histórica.

---

## Arquitetura Geral

**Fonte de Dados (MySQL)**  
→ Spark (Extract)  
→ Regras de Negócio (Transform)  
→ S3 / Data Lake (Load)  
→ Consumo Analítico (Athena / Spark SQL / BI)

---

## Tecnologias Utilizadas

- Python 3.11
- Apache Spark (PySpark)
- MySQL
- AWS S3 (via LocalStack)
- JDBC MySQL Connector
- Boto3
- Spark SQL

---

## Estrutura do Projeto

```
limitecredito/
├── limitecredito.py            # Orquestração principal do ETL
├── config/
│   └── config.py               # Variáveis de ambiente e configuração
├── etl/
│   ├── extract/
│   │   └── extract.py          # Camada de extração (MySQL → Spark)
│   ├── transform/
│   │   └── transform.py        # Regras de negócio e decisão de crédito
│   └── load/
│       └── load_s3.py          # Persistência no S3 (JSON particionado)
├── logs/
│   └── etl_logger.py           # Logger estruturado do ETL
├── jars/
│   └── mysql-connector-j-8.0.33.jar
└── README.md
```

---

## Fonte de Dados (Extract)

As seguintes tabelas são extraídas do banco **limite_credito_agro**:

- `cliente`
- `cliente_produto`
- `limite_credito`
- `negativacao`
- `produto_agro`
- `propriedades`

A extração é realizada via **Spark JDBC**, garantindo escalabilidade e paralelismo.

---

## Regras de Negócio (Transform)

A transformação central gera a **decisão de crédito por cliente PF**, aplicando as regras abaixo (ordem de prioridade):

1. **BLOQUEADO_RENDA**  
   - `grupo_familiar_renda < 500000`

2. **BLOQUEADO_NEGATIVACAO**  
   - Cliente negativado

3. **BLOQUEADO_SOCIOAMBIENTAL**  
   - Possui apontamentos socioambientais

4. **BLOQUEADO_RISCO**  
   - Limite comprometido

5. **SEM_LIMITE**  
   - Limite disponível ≤ 0

6. **LIBERADO**  
   - Cliente aprovado

### Cálculo de Limite

```
limite_disponivel = valor_limite_aprovado - coalesce(valor_limite_contratado, 0)
```

### Saída da Transformação

Campos finais:

- `cliente_id`
- `nome`
- `grupo_familiar_renda`
- `valor_limite_aprovado`
- `valor_limite_contratado`
- `limite_disponivel`
- `decisao_credito`

O ETL também gera **contagem por tipo de decisão** e exemplos de clientes liberados.

---

## Persistência no Data Lake (Load)

Os dados são gravados no **S3 (LocalStack)** em formato **JSON line-delimited**, com:

- Persistência **chunkada** por tamanho máximo de arquivo
- Prefixo versionado por data

### Exemplo de caminho no S3

```
s3://limite-credito/analises/dt=2026-01-13/part-00000.json
```

### Conteúdo do JSON

```json
{
  "cliente_id": 123,
  "nome": "João Silva",
  "grupo_familiar_renda": 750000,
  "valor_limite_aprovado": 300000,
  "valor_limite_contratado": 100000,
  "limite_disponivel": 200000
}
```

---

## Versionamento e Histórico

- Os dados são versionados por **dt_processamento**
- Planejado para evolução como **Tabela Gold**
- Base pronta para histórico de decisões (`decisao_credito_historico`)
- Persistência de **aprovados e bloqueados**, incluindo motivo da decisão

---

## Execução do ETL

### Pré-requisitos

- MySQL em execução
- LocalStack com S3 ativo
- Bucket criado:

```bash
awslocal s3 mb s3://limite-credito
```

### Execução correta

```bash
spark-submit \
  --jars jars/mysql-connector-j-8.0.33.jar \
  limitecredito.py
```

---

## Consumo Analítico (Próximos Passos)

O pipeline já está preparado para:

- Leitura direta via **Athena**
- Criação de **Glue Catalog**
- Consulta via **Spark SQL**
- Dashboards BI (Power BI / Superset / QuickSight)

---

## Status Atual

✔ ETL funcional end-to-end  
✔ Regras de negócio aplicadas  
✔ Persistência no Data Lake  
✔ Logging estruturado  
✔ Pronto para camada Gold e BI

---

## Próximas Evoluções Planejadas

- Criar tabela `decisao_credito_historico`
- Persistir motivos detalhados de bloqueio
- Converter para formato colunar (Parquet)
- Integrar Glue + Athena
- Implementar controle de qualidade de dados (DQ)

---

## Autor

Projeto desenvolvido como exercício prático de **Engenharia de Dados aplicada a Crédito Agro**, com foco em arquitetura, governança e analytics-ready pipelines.

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/mauroslucios/analise-de-credito-agropf)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mauro-lucio-pereira/)


