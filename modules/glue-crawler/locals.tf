locals {
  name = var.submodule-name == "" ? "${var.project-name}-${var.module-name}" : "${var.project-name}-${var.module-name}-${var.submodule-name}"
}