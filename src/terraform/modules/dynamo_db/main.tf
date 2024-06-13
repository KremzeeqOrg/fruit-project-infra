resource "aws_dynamodb_table" "api-db" {
  for_each     = var.dynamo_db_hash_keys
  name         = each.key
  hash_key     = each.value
  billing_mode = "PAY_PER_REQUEST"
  tags = {
    "env"   = var.env,
    "stack" = var.stack,
    "app"   = var.app
  }

  attribute {
    name = each.value
    type = "S"
  }
}
