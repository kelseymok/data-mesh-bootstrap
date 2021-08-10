resource "aws_glue_job" "this" {
  name     = local.name
  role_arn = aws_iam_role.this.arn

  number_of_workers = 2
  worker_type = "Standard"
  glue_version = "2.0"

  command {
    script_location = var.script-path
  }

  default_arguments = merge({
    "--job-language"                     = "python"
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.this.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--TempDir"                          = "s3://${data.aws_s3_bucket.this.bucket}/temp/"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${data.aws_s3_bucket.this.bucket}/spark-logs/"
  },var.additional-params)
}

data "aws_s3_bucket" "this" {
  bucket = var.output-bucket
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${local.name}/glue-job"
  retention_in_days = 14
}

data "aws_caller_identity" "current" {}