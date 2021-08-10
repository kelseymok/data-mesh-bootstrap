module "s3" {
  source = "../../modules/s3-bucket"

  bucket-name = "${local.project-name}-${local.module-name}-ingestion"
  force-destroy = true
}

resource "aws_s3_bucket_object" "this" {
  bucket = module.s3.bucket-name
  key    = "EmissionsByCountry.parquet/part-00000-a5120099-3f2e-437a-98c6-feb2845cdf28-c000.snappy.parquet"
  source = "EmissionsByCountry.parquet/part-00000-a5120099-3f2e-437a-98c6-feb2845cdf28-c000.snappy.parquet"
  etag = filemd5("EmissionsByCountry.parquet/part-00000-a5120099-3f2e-437a-98c6-feb2845cdf28-c000.snappy.parquet")
}

resource "aws_glue_catalog_database" "this" {
  name = "${local.project-name}-${local.module-name}"
}

module "ingestion-crawler" {
  source = "../../modules/glue-crawler"

  project-name = local.project-name
  module-name = local.module-name
  submodule-name = "ingestion"
  bucket-path = "${module.s3.bucket-name}/EmissionsByCountry.parquet"
  bucket-arn = module.s3.bucket-arn
  bucket-kms-arn = module.s3.kms-key-arn
  data-catalog-database-name = aws_glue_catalog_database.this.name
}