data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket-name
  force_destroy = var.force-destroy


  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  dynamic "grant" {
    for_each = (var.accessors == null ? [] : var.accessors.*.canonical-id)
    content {
      id = grant.value
      type = "CanonicalUser"
      permissions = ["READ"]
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.this.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.private
  block_public_policy     = var.private
  ignore_public_acls      = var.private
  restrict_public_buckets = var.private
}


resource "aws_s3_bucket_policy" "this" {
  count = var.accessors == null ? 0 : 1
  depends_on = [aws_s3_bucket_public_access_block.this]
  bucket = aws_s3_bucket.this.id

  policy = data.aws_iam_policy_document.allowed-to-read[0].json
}

data "aws_iam_policy_document" "allowed-to-read" {
  count = var.accessors == null ? 0 : 1
  statement {
    principals {
      identifiers = var.accessors.*.role
      type = "AWS"
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}