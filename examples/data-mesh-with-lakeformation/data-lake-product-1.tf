module "s3" {
  source = "../../modules/s3-bucket"

  bucket-name = "${local.project-name}-${local.module-name}-data"
  force-destroy = true
}

resource "aws_s3_bucket_object" "this" {
  bucket = module.s3.bucket-name
  key    = "EuropeBigThreeEmissions.parquet/part-00000-5dde5362-0505-4032-a812-f44e89581a41-c000.snappy.parquet"
  source = "EuropeBigThreeEmissions.parquet/part-00000-5dde5362-0505-4032-a812-f44e89581a41-c000.snappy.parquet"
  etag = filemd5("EuropeBigThreeEmissions.parquet/part-00000-5dde5362-0505-4032-a812-f44e89581a41-c000.snappy.parquet")
}

resource "aws_glue_catalog_database" "this" {
  name = "${local.project-name}-${local.module-name}-${local.submodule-name}"
}

module "crawler" {
  source = "../../modules/glue-crawler"

  project-name = local.project-name
  module-name = local.module-name
  submodule-name = local.submodule-name
  bucket-path = "${module.s3.bucket-name}/EuropeBigThreeEmissions.parquet"
  bucket-arn = module.s3.bucket-arn
  bucket-kms-arn = module.s3.kms-key-arn
  data-catalog-database-name = aws_glue_catalog_database.this.name
}

resource "aws_lakeformation_resource" "product-1" {
  arn = module.s3.bucket-arn
//  role_arn = everyone has a role to update their lakeformation resource?
}