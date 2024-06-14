variable "env" {
  type = string
}

variable "stack" {
  type = string
}

variable "app" {
  type = string
}

variable "dynamo_db_hash_keys" {
  type = map(any)
  default = {
    "fruit"            = "name",
    "cocktail-recipes" = "name",
    "food-recipes"     = "name"
  }
}


# variable "dynamo_db_hash_keys" {
#   type = map(any)
#   default = {
#     "fruit"            = {"hash_key" = "name"},
#     "cocktail-recipes" = "title",
#     "food-recipes"     = "hash_key"
#   }
# }

