import sys
import os
import pandas as pd
from s3fs import S3FileSystem

ENVIRONMENT = os.getenv(key="ENVIRONMENT", default="aws")

if ENVIRONMENT not in ["local", "aws"]:
    raise ValueError("""ENVIRONMENT must be "local" or "aws" only""")

elif ENVIRONMENT == "aws":
    try:
        from awsglue.utils import getResolvedOptions
        job_parameters = getResolvedOptions(
            sys.argv, 
            [
                "input_path",
                "output_path",
            ]
        )
    except ModuleNotFoundError:
        raise ModuleNotFoundError("""
        No module named 'awsglue' 
        ********
        For local development, don't forget to set the environment variable: ENVIRONMENT=local
        ********
        """)

elif ENVIRONMENT == "local":

    root_dir = os.path.dirname(os.path.realpath(__file__)).split("/data_transformation/")[0]
    job_parameters = {
        "input_path": f"{root_dir}/../../../EmissionsByCountry.parquet/",
        "output_path": f"{root_dir}/tmp/EmissionsGermany.parquet",
    }