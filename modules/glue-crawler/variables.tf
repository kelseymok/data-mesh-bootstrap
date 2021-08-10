

variable "project-name" {
  type = string
}

variable "module-name" {
  type = string
}

variable "submodule-name" {
  type = string
  default = ""
}

variable "excluded-files" {
  type = list(string)
  default = []
}

variable "bucket-path" {
  type = string
}

variable "bucket-kms-arn" {
  type = string
}

variable "bucket-arn" {
  type = string
}

variable "data-catalog-database-name" {
  type = string
}