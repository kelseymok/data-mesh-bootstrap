module "transformation-src-s3" {
  source = "../../modules/s3-bucket"

  bucket-name = "${local.project-name}-${local.module-name}-transformation-src"
  force-destroy = true
}

module "transformed-s3" {
  source = "../../modules/s3-bucket"

  bucket-name = "${local.project-name}-${local.module-name}-transformation"
  force-destroy = true
}

module "transformation-glue-job" {
  source = "../../modules/glue-job"

  project-name = local.project-name
  module-name = local.module-name
  submodule-name = "transformation"
  script-path = "s3://${module.transformation-src-s3.bucket-name}/main.py"
  output-bucket = module.transformed-s3.bucket-name
  additional-params = {
    "--extra-py-files":                   "s3://${module.transformation-src-s3.bucket-name}/data_transformation-0.1-py3.7.egg", # https://docs.aws.amazon.com/glue/latest/dg/reduced-start-times-spark-etl-jobs.html
    "--input_path":                       "s3://${module.s3.bucket-name}/EmissionsByCountry.parquet/",
    "--output_path":                      "s3://${module.transformed-s3.bucket-name}/Transformed.parquet/",

  }
}

resource "null_resource" "create-egg" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "cd data-transformation-code && python setup.py bdist_egg"
    interpreter = ["bash", "-c"]
  }
}

resource "aws_s3_bucket_object" "transformation-egg" {
  bucket = module.transformation-src-s3.bucket-name
  key    = "data_transformation-0.1-py3.7.egg"
  source = "data-transformation-code/dist/data_transformation-0.1-py3.7.egg"
  depends_on = [null_resource.create-egg]
}

resource "aws_s3_bucket_object" "transformation-src" {
  bucket = module.transformation-src-s3.bucket-name
  key    = "main.py"
  source = "data-transformation-code/src/main.py"
  etag = filemd5("data-transformation-code/src/main.py")
  depends_on = [null_resource.create-egg]
}

module "transformation-crawler" {
  source = "../../modules/glue-crawler"

  project-name = local.project-name
  module-name = local.module-name
  submodule-name = "transformation"
  bucket-path = "${module.transformed-s3.bucket-name}/Transformed.parquet"
  bucket-arn = module.transformed-s3.bucket-arn
  bucket-kms-arn = module.transformed-s3.kms-key-arn
  data-catalog-database-name = aws_glue_catalog_database.this.name
}