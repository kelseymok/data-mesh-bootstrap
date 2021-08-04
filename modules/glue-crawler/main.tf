resource "aws_glue_crawler" "this" {
  database_name = var.data-catalog-database-name
  name          = "${var.project-name}-${var.module-name}-${var.submodule-name}-crawler"
  role          = aws_iam_role.this.arn
  table_prefix = "${var.project-name}_${var.module-name}_"

  s3_target {
    path = "s3://${var.bucket-path}"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.project-name}-${var.module-name}-${var.submodule-name}/glue-crawler"
  retention_in_days = 14
}