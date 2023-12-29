resource "aws_dynamodb_table" "local_table" {
  name             = "LocalTable"
  billing_mode     = "PROVISIONED"
  read_capacity    = 20
  write_capacity   = 20
  hash_key         = "UserId"
  range_key        = "GameTitle"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  attribute {
    name = "TopScore"
    type = "N"
  }

  global_secondary_index {
    name               = "GameTitleIndex"
    projection_type    = "INCLUDE"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    read_capacity      = 10
    write_capacity     = 10
    non_key_attributes = ["UserId"]
  }
}


resource "aws_dynamodb_table" "global_table" {
  name             = "GlobalTable"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "UserId"
  range_key        = "TotalScore"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "TotalScore"
    type = "N"
  }

  dynamic "replica" {
    for_each = var.dynamodb_replica_regions
    content {
      region_name = replica.value
    }
  }
}

resource "aws_dynamodb_table" "actions_table" {
  name           = "ActionsTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ActionId"
  range_key      = "Type"

  attribute {
    name = "ActionId"
    type = "S"
  }

  attribute {
    name = "Type"
    type = "S"
  }

  ttl {
    attribute_name = "ExpiredAt"
    enabled        = true
  }
}

resource "aws_dynamodb_table_item" "local_item" {
  table_name = aws_dynamodb_table.local_table.name
  hash_key   = aws_dynamodb_table.local_table.hash_key
  range_key  = aws_dynamodb_table.local_table.range_key
  item = jsonencode({
    UserId    = { "S" = "GNOIfrfOKmXdD03VCl6ID6LJ" }
    GameTitle = { "S" = "TicTacToe" }
    TopScore  = { "N" = "32" }
  })
  depends_on = [aws_dynamodb_table.local_table]
}

resource "aws_dynamodb_table_item" "global_item" {
  table_name = aws_dynamodb_table.global_table.name
  hash_key   = aws_dynamodb_table.global_table.hash_key
  range_key  = aws_dynamodb_table.global_table.range_key
  item = jsonencode({
    UserId     = { "S" = "GNOIfrfOKmXdD03VCl6ID6LJ" }
    TotalScore = { "N" = "32" }
  })
  depends_on = [aws_dynamodb_table.global_table]
}

# this item will be promptly removed upon application as its ttl has already passed
resource "aws_dynamodb_table_item" "action_item" {
  table_name = aws_dynamodb_table.actions_table.name
  hash_key   = aws_dynamodb_table.actions_table.hash_key
  range_key  = aws_dynamodb_table.actions_table.range_key
  item = jsonencode({
    ActionId  = { "S" = "D03VCl6ID6LJGNOIfrfOKmXd" }
    Type      = { "S" = "DispatchNotification" }
    ExpiredAt = { "N" = "1703173897" }
  })
  depends_on = [aws_dynamodb_table.actions_table]
}
