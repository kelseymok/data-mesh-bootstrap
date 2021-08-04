resource "aws_lakeformation_data_lake_settings" "this" {
  admins = [aws_iam_role.lake-formation-admin.arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/federated-admin"]
}

resource "aws_lakeformation_permissions" "product-1-glue-catalog" {
  principal        = aws_iam_role.lake-formation-reader.arn
  permissions = ["SELECT"]

  table {
    database_name       = aws_glue_catalog_database.this.name
    catalog_id = data.aws_caller_identity.current.account_id
    wildcard = true
  }
}