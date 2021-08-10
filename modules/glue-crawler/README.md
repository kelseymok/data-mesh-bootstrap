# Glue Crawler
This module creates a simple Glue Crawler for objects in an S3 bucket

## Example
```terraform
module "s3" {
  source = "../../modules/s3-bucket"

  bucket-name = "my-awesome-bucket"
  force-destroy = true
}

resource "aws_glue_catalog_database" "this" {
  name = "my-awesome-database"
}

module "crawler" {
  source = "../../modules/glue-crawler"

  project-name = local.project-name
  module-name = local.module-name
  submodule-name = local.submodule-name
  bucket-path = "${module.s3.bucket-name}/my-awesome-file.parquet"
  bucket-arn = module.s3.bucket-arn
  bucket-kms-arn = module.s3.kms-key-arn
  data-catalog-database-name = aws_glue_catalog_database.this.name
  excluded-files = ["*.egg"]
}
```

## Inputs
| Output | Description | Type | Required? | Default |
| --- | --- | --- | --- | --- |
| project-name | Name of the project | string | yes | |
| module-name | Name of the module | string | yes | |
| submodule-name | Name of the esubmodule | string | no | "" |
| excluded-files | List of globs representing files that are not to be crawled | list(string) | no | [] |
| bucket-path | s3 path of the files to be crawled | string | yes | |
| bucket-kms-arn | kms arn for the bucket | string | yes | |
| bucket-arn | s3 bucket arn | string | yes | |
| data-catalog-database-name | Glue Catalog Database name| string | yes |

## Outputs
| Output | Description | Type |
| --- | --- | --- |
| name | Name of the Glue Crawler | string |
