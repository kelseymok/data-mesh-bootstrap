resource "aws_iam_role" "lake-formation-reader" {
  name = "${local.project-name}-${local.module-name}-lake-formation-reader"

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

data "aws_iam_policy_document" "lake-formation-reader" {
  statement {
    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:List*"
    ]
    resources = ["${module.s3.bucket-arn}/athena-results/*"]
  }
}

resource "aws_iam_policy" "lake-formation-reader" {
  policy = data.aws_iam_policy_document.lake-formation-reader.json
}

resource "aws_iam_role_policy_attachment" "lake-formation-reader" {
  policy_arn = aws_iam_policy.lake-formation-reader.arn
  role = aws_iam_role.lake-formation-reader.id
}

resource "aws_iam_role_policy_attachment" "lake-formation-reader-athena" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
  role = aws_iam_role.lake-formation-reader.id
}