data "aws_caller_identity" "current" {}

locals {
  map_users = []
  map_roles = []
  map_accounts = []
}
