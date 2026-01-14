from pyspark.sql.functions import col, when, coalesce, lit
from logs.etl_logger import ETLLogger


class Transformer:
    @staticmethod
    def transform_business_rules(df_cliente, df_limite, df_neg):
        ETLLogger.log_event(
            event="Transformação",
            action="Aplicar regra de negócio - decisão de crédito"
        )

        df_decisao = (
            df_cliente.alias("c")
            .join(
                df_limite.alias("lc"),
                col("lc.cliente_id") == col("c.cliente_id"),
                "inner"
            )
            .join(
                df_neg.alias("n"),
                col("n.cliente_id") == col("c.cliente_id"),
                "left"
            )
            .filter(col("c.tipo_pessoa") == "PF")
            .withColumn(
                "limite_disponivel",
                col("lc.valor_limite_aprovado")
                - coalesce(col("lc.valor_limite_contratado"), lit(0))
            )
            .withColumn(
                "decisao_credito",
                when(col("c.grupo_familiar_renda") < 500000, "BLOQUEADO_RENDA")
                .when(coalesce(col("n.negativado"), lit(False)), "BLOQUEADO_NEGATIVACAO")
                .when(coalesce(col("n.possui_apontamentos"), lit(False)), "BLOQUEADO_SOCIOAMBIENTAL")
                .when(coalesce(col("n.limite_comprometido"), lit(False)), "BLOQUEADO_RISCO")
                .when(col("limite_disponivel") <= 0, "SEM_LIMITE")
                .otherwise("LIBERADO")
            )

            .select(
                col("c.cliente_id"),
                col("c.nome"),
                col("c.grupo_familiar_renda"),
                col("lc.valor_limite_aprovado"),
                col("lc.valor_limite_contratado"),
                col("limite_disponivel"),
                col("decisao_credito")
            )
        )

        ETLLogger.log_event(event="Contagem de decisões de crédito", action="Transformação") # noqa
        df_decisao.groupBy("decisao_credito").count().show()

        ETLLogger.log_event(event="Exemplo de decisões de crédito LIBERADO", action="Transformação") # noqa
        df_decisao.filter(col("decisao_credito") == "LIBERADO").show(truncate=False) # noqa

        return df_decisao
# End of transform.py