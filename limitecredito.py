from pyspark.sql import SparkSession
import traceback

from logs.etl_logger import ETLLogger
from config.config import LOCASTACK_ENDPOINT, LOCASTACK_REGION, S3_ACCESS_KEY, S3_SECRET_KEY, S3_BUCKET, S3_PREFIX, MAX_FILE_SIZE_BYTES # noqa
from etl.extract.extract import Extract
from etl.trasnform.transform import Transformer
from etl.load.load_s3 import S3Loader


def main():
    ETLLogger.log_event(event="Início do processo ETL", action="MAIN")
    spark = (SparkSession.builder
        .appName("LimiteCreditoETL")
        .config("spark.jars", "./jars/mysql-connector-j-8.0.33.jar")
        .config("spark.hadoop.fs.s3a.endpoint", LOCASTACK_ENDPOINT)
        .config("spark.hadoop.fs.s3a.access.key", S3_ACCESS_KEY)
        .config("spark.hadoop.fs.s3a.secret.key", S3_SECRET_KEY)
        .config("spark.hadoop.fs.s3a.path.style.access", "true")
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false")
        .config("spark.hadoop.fs.s3a.region", LOCASTACK_REGION)
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") # noqa
        .getOrCreate()
    )

    try:
        extract = Extract(spark)
        transformer = Transformer()
        loader = S3Loader()

        df_cliente = extract.extrat("cliente")
        df_limite = extract.extrat("limite_credito")
        df_negativacao = extract.extrat("negativacao")
        

        df_decisao_credito = transformer.transform_business_rules(df_cliente, df_limite, df_negativacao) # noqa
        df_decisao_credito.show(truncate=False)

        loader.load_as_chunked_json_to_s3(df_decisao_credito, S3_BUCKET, S3_PREFIX, MAX_FILE_SIZE_BYTES) # noqa

        ETLLogger.log_event(event="Processo ETL concluído com sucesso", action="MAIN")
    except Exception:
        ETLLogger.log_event(
            event="Processo ETL falhou",
            action="MAIN",
            error=traceback.format_exc()
        )
    finally:
        spark.stop()


if __name__ == "__main__":
    main()