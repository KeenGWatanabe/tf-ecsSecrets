resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name_prefix}-app-ecs-tasks"
  description = "Allow inbound access from ALB only"
  vpc_id      = var.vpc_id # aws_vpc.main.id 

  ingress {
    protocol        = "tcp"
    from_port       = 5000
    to_port         = 5000
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # Security group for VPC endpoints
# resource "aws_security_group" "vpc_endpoint" {
#   name        = "vpc-endpoint-sg"
#   description = "Security group for VPC endpoints"
#   vpc_id      = var.vpc_id #aws_vpc.main.id 

#   ingress {
#     description = "HTTPS from VPC"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.selected.cidr_block] # Restrict to VPC CIDR aws_vpc.main
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.name_prefix}-vpc-endpoint-sg"
#   }
# }