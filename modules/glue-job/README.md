# Glue Job
This module creates a Glue job (version 2.0) from Python scripts that exist in a bucket somewhere

## Example
```terraform
module "source-code-bucket" {
  source = "../../modules/s3-bucket"

  bucket-name = "my-awesome-bucket"
  force-destroy = true
}

module "output-bucket" {
  source = "../../modules/s3-bucket"

  bucket-name = "my-awesome-output-bucket"
  force-destroy = true
}

module "glue-job" {
  source = "../../modules/glue-job"

  project-name = "my-awesome-project"
  module-name = "my-awesome-module"
  submodule-name = "my-awesome-submodule"
  script-path = "s3://${module.source-code-bucket.bucket-name}/main.py"
  output-path = module.output-bucket.bucket-name
  additional-params = {
    "--extra-py-files":                   "s3://${module.source-code-bucket.bucket-name}/my-awesome-library-0.1-py3.egg", # https://docs.aws.amazon.com/glue/latest/dg/reduced-start-times-spark-etl-jobs.html
    "--some_awesome_param":               "coolest-param-ever",
  }
}
```
## Inputs
| Output | Description | Type | Required? |
| --- | --- | --- | --- |
| project-name | Name of the project | string | yes |
| module-name | Name of the module | string | yes |
| submodule-name | Name of the esubmodule | string | no |
| output-bucket | s3 path for job outputs (like logs/tmp directory) | string | yes |
| script-path | s3 path of the location of your main.py | string | yes |
| additional-params | Additional params for the glue job (like input and output buckets for your actual data) | string | no |

## Outputs
| Output | Description | Type |
| --- | --- | --- |
| name | Name of the Glue job | string |

## Notes
* AWS Glue 2.0 (at the time of writing) [supports Python 3.7](https://docs.aws.amazon.com/glue/latest/dg/release-notes.html)