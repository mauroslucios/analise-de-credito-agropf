import traceback
from pyspark.sql import SparkSession
from config.config import MYSQL_URL, MYSQL_DRIVER, MYSQL_USER, MYSQL_PASSWORD
from logs.etl_logger import ETLLogger


class Extract:

    def __init__(self, spark):
        self.spark = spark

    def extrat(self, table_name):
        try:
            df = (
                self.spark.read.format("jdbc")
                .option("url", MYSQL_URL)
                .option("driver", MYSQL_DRIVER)
                .option("user", MYSQL_USER)
                .option("password", MYSQL_PASSWORD)
                .option("dbtable", table_name)
                .option("driver", "com.mysql.cj.jdbc.Driver")
                .load()
            )
            ETLLogger.log_event(
                    event="Extração",
                    db="limite_credito_agro",
                    table=table_name,
                    action="Lendo dados",
                    result=f"{df.count()} registros extraídos",
                )
            return df
        except Exception:
            ETLLogger.log_event(
                event="Extração",
                db="elysium",
                table=table_name,
                action="Lendo dados",
                result=f"Erro ao extrair dados",
                error=traceback.format_exc()
            )
            raise