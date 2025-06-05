data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  # Optional: Filter by tags if needed
  filter {
    name   = "tag:Type"
    values = ["private"] # Adjust to match your subnet naming
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id # Your existing vpc_id variable
}


data "aws_caller_identity" "current" {
  id = "current"
}