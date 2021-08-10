resource "aws_glue_crawler" "this" {
  database_name = var.data-catalog-database-name
  name          = "${local.name}-crawler"
  role          = aws_iam_role.this.arn
  table_prefix = replace("${local.name}-", "-", "_")

  s3_target {
    path = "s3://${var.bucket-path}"
    exclusions = var.excluded-files

  }
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${local.name}/glue-crawler"
  retention_in_days = 14
}