variable "project-name" {
  type = string
}

variable "module-name" {
  type = string
}

variable "submodule-name" {
  type = string
}

variable "output-bucket" {
  type = string
  description = "Output bucket"
}

variable "script-path" {
  description = "Script path in bucket (my-bucket/ingestion.py)"
  type = string
}

variable "additional-params" {
  type = map(string)
  default = {}
}