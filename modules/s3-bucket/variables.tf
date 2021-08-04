variable "bucket-name" {
  type = string
}

variable "force-destroy" {
  description = "Force destroy even when there are objects in bucket"
  default     = false
}

variable "accessors" {
  type = list(object({
    role = string
    canonical-id = string
  }))
  default = null
}

variable "private" {
  type = bool
  default = true
}