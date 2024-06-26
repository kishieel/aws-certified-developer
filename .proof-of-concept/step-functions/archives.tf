data "archive_file" "place_order" {
  type = "zip"
  source_dir = "./lambdas/place-order"
  output_path = "./lambdas/place-order/dist.zip"
  excludes = ["dist.zip"]
}

data "archive_file" "create_order" {
  type = "zip"
  source_dir = "./lambdas/create-order"
  output_path = "./lambdas/create-order/dist.zip"
  excludes = ["dist.zip"]
}

data "archive_file" "reject_order" {
  type = "zip"
  source_dir = "./lambdas/reject-order"
  output_path = "./lambdas/reject-order/dist.zip"
  excludes = ["dist.zip"]
}
