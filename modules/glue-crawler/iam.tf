resource "aws_iam_role" "this" {
  name = "${var.project-name}-${var.module-name}-${var.submodule-name}-glue"
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

data "aws_iam_policy_document" "assume-role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = ["glue.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "glue-service-role" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketAcl"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::aws-glue-*/*",
      "arn:aws:s3:::*/*aws-glue-*/*",
      "arn:aws:s3:::aws-glue-*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      var.bucket-arn,
      "${var.bucket-arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:CreateBucket"
    ]

    resources = [
      "arn:aws:s3:::aws-glue-*"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  role = aws_iam_role.this.id
  policy_arn = aws_iam_policy.s3.arn
}

data "aws_iam_policy_document" "kms" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      var.bucket-kms-arn,
    ]
  }

  statement {
    actions = [
      "kms:ListAliases",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_policy" "kms" {
  policy = data.aws_iam_policy_document.kms.json
}

resource "aws_iam_role_policy_attachment" "kms" {
  role       = aws_iam_role.this.id
  policy_arn = aws_iam_policy.kms.arn
}


data "aws_iam_policy_document" "cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:/aws-glue/*",
      aws_cloudwatch_log_group.this.arn
    ]
  }
}

resource "aws_iam_policy" "cloudwatch" {
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.this.id
  policy_arn = aws_iam_policy.cloudwatch.arn
}
