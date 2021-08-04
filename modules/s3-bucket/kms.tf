resource "aws_kms_alias" "this" {
  name          = "alias/${var.bucket-name}"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_key" "this" {
  description             = "This key is used to decrypt/encrypt ${var.bucket-name}"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  dynamic "statement" {
    for_each = (var.accessors == null ? [] : [{ identifiers : var.accessors.*.role }])
    content {
      actions = [
        "kms:Encrypt", // TODO: Remove
        "kms:Decrypt",
        "kms:ReEncrypt*", //TODO: Remove
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]

      principals {
        identifiers = tolist(statement.value["identifiers"])
        type        = "AWS"
      }
    }
  }

  statement {
    actions = [
      "kms:*",
    ]

    resources = [
      "*"
    ]

    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
  }
}