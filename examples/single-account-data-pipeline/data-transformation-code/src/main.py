import os

from pyspark.sql import SparkSession

from data_transformation.config import job_parameters
from data_transformation.transformation import Transformer

# By sticking with standard Spark, we can avoid having to deal with Glue dependencies locally
# If developing outside of the data-derp container, don't forget to set the environment variable: ENVIRONMENT=local
ENVIRONMENT = os.getenv(key="ENVIRONMENT", default="aws")

# ---------- Part III: Run Da Ting (for Part II, see data_transformation/transformation.py) ---------- #

print("Starting Spark Job")
print()

spark = SparkSession \
    .builder \
    .appName("Glue Data Transformation") \
    .getOrCreate()

# Enable Arrow-based columnar data transfers
# In Spark 2.4.3 (the version used in AWS Glue), Apache Arrow must be enabled to use Pandas UDFs
# https://spark.apache.org/docs/2.4.3/sql-pyspark-pandas-with-arrow.html
# For newer versions of Spark, Arrow is enabled by default.
spark.conf.set("spark.sql.execution.arrow.enabled", "true")

print("Running Transformer")
Transformer(spark, job_parameters).run()

print()
print("Spark Job Complete")
