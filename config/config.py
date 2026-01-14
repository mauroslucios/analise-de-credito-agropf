import os
from dotenv import load_dotenv
load_dotenv()  # Carrega .env

MYSQL_URL = os.getenv("MYSQL_URL", "jdbc:mysql://172.22.1.2:3306/limite_credito_agro") # noqa
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "123456")
MYSQL_DRIVER = os.getenv("MYSQL_DRIVER", "com.mysql.cj.jdbc.Driver")
MAX_FILE_SIZE_BYTES = int(os.getenv("MAX_FILE_SIZE_BYTES", 1 * 1024 * 1024))

LOCASTACK_ENDPOINT = os.getenv("LOCASTACK_ENDPOINT", "http://localhost:4566")
LOCASTACK_REGION = os.getenv("LOCASTACK_REGION", "us-east-1")
S3_ACCESS_KEY = os.getenv("S3_ACCESS_KEY", "test")
S3_SECRET_KEY = os.getenv("S3_SECRET_KEY", "test")
S3_BUCKET = os.getenv("S3_BUCKET", "limite-credito")
S3_PREFIX = os.getenv("S3_PREFIX", "analises/")