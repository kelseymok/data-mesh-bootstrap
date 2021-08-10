from pyspark.sql.types import *

def get_expected_metadata():

    co2_temperatures_country_expected_count = 23375
    co2_temperatures_country_expected_schema = StructType([
        StructField("Year", IntegerType(), True),
        StructField("Country", StringType(), True),
        StructField("TotalEmissions", FloatType(), True),
        StructField("PerCapitaEmissions", FloatType(), True),
        StructField("ShareOfGlobalEmissions", FloatType(), True)
        ]
    )

    expected_output_metadata = {
        "output": {"count": co2_temperatures_country_expected_count, "schema": co2_temperatures_country_expected_schema},
    }
    
    return expected_output_metadata
