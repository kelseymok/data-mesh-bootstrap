output "bucket-name" {
  value = aws_s3_bucket.this.id
}

output "bucket-arn" {
  value = aws_s3_bucket.this.arn
}

output "kms-key-arn" {
  value = aws_kms_key.this.arn
}