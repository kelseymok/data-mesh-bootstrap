from typing import Dict
from pyspark.sql import DataFrame, Column
import pyspark.sql.functions as F
from pyspark.sql.session import SparkSession
from pyspark.sql.types import *

class Transformer:

    def __init__(self, spark: SparkSession, parameters: Dict[str, str], boss_level: bool = True):
        self.spark = spark
        self.parameters = parameters
        self.boss_level = boss_level
        return

    @staticmethod
    def get_country_emissions(co2_df: DataFrame) -> DataFrame:
        country_emissions = co2_df \
            .filter(F.col("Entity") != F.lit("World")) \
            .select(
                F.col("Year"),
                F.col("Entity").alias("Country"),
                F.col("Annual_CO2_emissions").cast(FloatType()).alias("TotalEmissions"),
                F.col("Per_capita_CO2_emissions").cast(FloatType()).alias("PerCapitaEmissions"),
                F.col("Share_of_global_CO2_emissions").cast(FloatType()).alias("ShareOfGlobalEmissions"),
            )
        return country_emissions

    def run(self):
        print("Running...")
        print("Parameters")
        print(self.parameters)
        input_df: DataFrame = self.spark.read.format("parquet").load(self.parameters["input_path"])
        print("Input DF")
        print(input_df)
        country_emissions: DataFrame = self.get_country_emissions(input_df)
        print("Country Emissions")
        print(country_emissions)
        country_emissions.coalesce(1).orderBy("Year") \
            .write.format("parquet").mode("overwrite") \
            .save(self.parameters["output_path"])

        return
