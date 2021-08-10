import pytest
import sys
import os

from shutil import rmtree
from pytest_mock.plugin import MockerFixture
from test_utils.pyspark import TestPySpark

from typing import List, Union

import pyspark.sql.functions as F
from pyspark.sql.types import *

import pandas as pd
import numpy as np
from datetime import datetime

from data_transformation.transformation import Transformer
from debugger import debug
from transformation_expected import get_expected_metadata

class TestTransformation(TestPySpark):

    @classmethod
    def setup_class(cls): # runs before each and every test
        cls.spark = cls.start_spark()
        root_dir = os.path.dirname(os.path.realpath(__file__)).split("/data-transformation-code/")[0]
        cls.parameters = {
        "input_path": f"{root_dir}/EmissionsByCountry.parquet/",
        "output_path": f"{root_dir}/data-transformation-code/tmp/EmissionsGermany.parquet",
        }
        cls.transformer = Transformer(cls.spark, cls.parameters)
        return

    @classmethod
    def teardown_class(cls):
        cls.stop_spark()
        output_paths = cls.parameters.values()
        for path in output_paths:
            if ("/tmp/" in path) and os.path.exists(path):
                rmtree(path.rsplit("/", 1)[0])

    @staticmethod
    def prepare_frame(
        df: pd.DataFrame, column_order: List[str] = None, sort_keys: List[str] = None,
        ascending: Union[bool, List[bool]] = True, reset_index: bool = True):
        """Prepare Pandas DataFrame for equality check"""
        if column_order is not None: df = df.loc[:, column_order]
        if sort_keys is not None: df = df.sort_values(sort_keys, ascending=ascending)
        if reset_index: df = df.reset_index(drop=True)
        return df

    def test_get_country_emissions(self):
        input_pandas = pd.DataFrame({
            "Year": [1999, 2000, 2001, 2020, 2021],
            "Entity" : ["World", "World", "World", "Fiji", "Argentina"],
            "Annual_CO2_emissions": [1.0, 2.0, 3.0, 4.0, 5.0],
            "Per_capita_CO2_emissions": [1.0, 2.0, 3.0, 4.0, 5.0],
            "Share_of_global_CO2_emissions": [0.5, 0.5, 0.5, 0.5, 0.5]
        })
        input_schema = StructType([
            StructField("Year", IntegerType(), True),
            StructField("Entity", StringType(), True),
            StructField("Annual_CO2_emissions", FloatType(), True),
            StructField("Per_capita_CO2_emissions", FloatType(), True),
            StructField("Share_of_global_CO2_emissions", FloatType(), True),
        ])
        input_df = self.spark.createDataFrame(input_pandas, input_schema)

        expected_columns = ["Year", "Country", "TotalEmissions", "PerCapitaEmissions", "ShareOfGlobalEmissions"]
        expected_pandas = pd.DataFrame({
            "Year": pd.Series([2020, 2021], dtype=np.dtype("int32")),
            "Country" : pd.Series(["Fiji", "Argentina"], dtype=str),
            "TotalEmissions": pd.Series([4.0, 5.0], dtype=np.dtype("float32")),
            "PerCapitaEmissions": pd.Series([4.0, 5.0], dtype=np.dtype("float32")),
            "ShareOfGlobalEmissions": pd.Series([0.5, 0.5], dtype=np.dtype("float32"))
        })
        expected_pandas = self.prepare_frame(
            expected_pandas,
            column_order=expected_columns, # ensure column order
            sort_keys=["Year", "Country"], # ensure row order
        )
        output_df = self.transformer.get_country_emissions(input_df)
        output_pandas: pd.DataFrame = output_df.toPandas()
        output_pandas = self.prepare_frame(
            output_pandas,
            column_order=expected_columns, # ensure column order
            sort_keys=["Year", "Country"], # ensure row order
        )
        print("Schemas:")
        print(expected_pandas.dtypes)
        print(output_pandas.dtypes)
        print("Contents:")
        print(expected_pandas)
        print(output_pandas)

        assert list(output_pandas.columns) == expected_columns # check column names and order
        assert "World" not in output_pandas["Country"].str.title().values
        assert output_pandas.equals(expected_pandas) # check contents and data types

    def test_run(self, mocker: MockerFixture):
        self.transformer.run()

        output_path_keys = [
            "output_path",
        ]
        output_path_values = [self.parameters[k] for k in output_path_keys]
        expected_metadata_dict = get_expected_metadata()
        expected_metadata = [expected_metadata_dict[k.replace("_path", "")] for k in output_path_keys]

        for (path, expected) in list(zip(output_path_values, expected_metadata)):
            files = os.listdir(path)
            snappy_parquet_files = [x for x in files if x.endswith(".snappy.parquet")]
            assert (True if len(snappy_parquet_files) == 1 else False)
            assert (True if "_SUCCESS" in files else False)

            df = self.spark.read.parquet(path)
            assert df.count() == expected["count"]
            assert df.schema == expected["schema"]


if __name__ == '__main__':
    pytest.main(sys.argv)
