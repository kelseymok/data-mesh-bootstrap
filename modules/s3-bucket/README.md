# SBucket
This module creates an encrypted (KMS) S3 bucket with optional ability to supply a list of accessors (for the bucket and KMS key)

## Example
```terraform
module "s3" {
  source = "../../modules/s3-bucket"

  bucket-name = "my-awesome-bucket"
  force-destroy = true
}

resource "aws_s3_bucket_object" "this" {
  bucket = module.s3.bucket-name
  key    = "some-dir/my-awesome-file.parquet"
  source = "my-host-dir/my-awesome-file.parquet"
  etag = filemd5("my-host-dir/my-awesome-file.parquet")
}
```