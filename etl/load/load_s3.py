import json
import boto3
from pyspark.sql.functions import col
from logs.etl_logger import ETLLogger
from config.config import LOCASTACK_ENDPOINT
from datetime import date

dt_processamento = date.today().isoformat()
s3_prefix = f"analises/decisao_credito/dt={dt_processamento}/"


class S3Loader:

    @staticmethod
    def s3_client():
        return boto3.client(
            "s3",
            endpoint_url=LOCASTACK_ENDPOINT,
            aws_access_key_id="test",
            aws_secret_access_key="test",
            region_name="us-east-1"
        )

    @staticmethod
    def load_as_chunked_json_to_s3(df, bucket, prefix, max_bytes):
        ETLLogger.log_event(event="Carga para S3 iniciada", action="LOAD_S3")

        s3 = S3Loader.s3_client()

        approved_iter = (
            df.toLocalIterator()
        )

        batch = []
        batch_bytes = 0
        file_index = 0

        def flush_batch(batch_list, idx):
            if not batch_list:
                return

            body = "\n".join(batch_list).encode("utf-8")
            clean_prefix = prefix.rstrip("/")
            key = f"{clean_prefix}/part-{idx:05d}.json"

            s3.put_object(
                Bucket=bucket,
                Key=key,
                Body=body
            )

            ETLLogger.log_event(
                    event="Carga S3",
                    action="Upload",
                    result=f"{key} -> {len(batch_list)} registros"
                )

        for row in approved_iter:
            rec = {
                "cliente_id": int(row["cliente_id"]),
                "nome": row["nome"],
                "grupo_familiar_renda": float(row["grupo_familiar_renda"]),
                "valor_limite_aprovado": float(row["valor_limite_aprovado"]),
                "valor_limite_contratado": float(row["valor_limite_contratado"]),
                "limite_disponivel": float(row["limite_disponivel"]),
                "decisao_credito": row["decisao_credito"],
                "dt_processamento": dt_processamento
            }


            j = json.dumps(rec, ensure_ascii=False)
            j_bytes = j.encode("utf-8")

            if batch_bytes + len(j_bytes) > max_bytes:
                flush_batch(batch, file_index)
                batch = []
                batch_bytes = 0
                file_index += 1

            batch.append(j)
            batch_bytes += len(j_bytes)

        # flush final
        flush_batch(batch, file_index)

        ETLLogger.log_event(event="Carga para S3 concluída", action="LOAD_S3")
