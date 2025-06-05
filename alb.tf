resource "aws_lb" "app" {
  name               = "${var.name_prefix}${random_id.suffix.hex}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.alb_subnet_ids # data.aws_subnets.public[0].id 

  enable_deletion_protection = false

  tags = {
    Environment = "production"
    Application = "${var.name_prefix}-app"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.name_prefix}-app-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id # aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 3
    path                = "/health"
    unhealthy_threshold = 2
  }
}

# 1. Request or import an SSL certificate (ACM)
resource "aws_acm_certificate" "app" {
  domain_name       = "ce-grp-4.sctp-sandbox.com"  # Replace with your domain
  validation_method = "DNS"            # or "EMAIL"

  lifecycle {
    create_before_destroy = true
  }
}

# 2. HTTPS Listener (443)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"  # Recommended policy
  certificate_arn   = aws_acm_certificate.app.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# 3. Update HTTP Listener (80) to redirect to HTTPS
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    type             = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
   
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-app-alb-sg"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = var.vpc_id #aws_vpc.main.id 

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name_prefix}-app-alb-sg"
  }
}