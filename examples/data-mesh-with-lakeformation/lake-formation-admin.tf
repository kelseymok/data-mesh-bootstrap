resource "aws_iam_role" "lake-formation-admin" {
  name = "${local.project-name}-${local.module-name}-lake-formation-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/federated-admin"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "lake-formation-admin" {
  statement {
    actions = [
      "lakeformation:*",
      "cloudtrail:DescribeTrails",
      "cloudtrail:LookupEvents",
      "glue:GetDatabase",
      "glue:CreateDatabase",
      "glue:UpdateDatabase",
      "glue:DeleteDatabase",
      "glue:SearchTables",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:Get*",
      "glue:List*",
      "glue:BatchGetWorkflows",
      "glue:DeleteWorkflow",
      "glue:GetWorkflowRuns",
      "glue:StartWorkflowRun",
      "glue:GetWorkflow",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:GetBucketAcl",
      "iam:ListUsers",
      "iam:ListRoles",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "cloudformation:*",
      "elasticmapreduce:*",
      "tag:Get*",
      "glue:BatchGetCrawlers",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = ["*"]
  }
  //  statement {
  //    actions = ["iam:PassRole"]
  //    resources = [
  //      "arn:aws:iam::*:role/LF-GlueServiceRole",
  //      "arn:aws:iam::*:role/LF-EMR-Notebook*"
  //    ]
  //  }
}

resource "aws_iam_policy" "lake-formation-admin" {
  policy = data.aws_iam_policy_document.lake-formation-admin.json
}

resource "aws_iam_role_policy_attachment" "lake-formation-admin" {
  policy_arn = aws_iam_policy.lake-formation-admin.arn
  role = aws_iam_role.lake-formation-admin.id
}

resource "aws_iam_role_policy_attachment" "lake-formation-admin-lfcrossaccountmanager" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationCrossAccountManager"
  role = aws_iam_role.lake-formation-admin.id
}

resource "aws_iam_role_policy_attachment" "lake-formation-admin-ec2read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role = aws_iam_role.lake-formation-admin.id
}