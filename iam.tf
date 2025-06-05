resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role-${var.name_prefix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow" 
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

## Attach ECR, Logging policy
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Permissions for CloudWatch
resource "aws_iam_role_policy" "ecs_logging" {
  name = "ecs-execution-logs"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
          ],
        Resource = [
          "${aws_cloudwatch_log_group.ecs_logs.arn}:*",
          "${aws_cloudwatch_log_group.xray.arn}:*"
        ] #"arn:aws:logs:us-east-1:255945442255:log-group:/ecs/${var.name_prefix}-app:*"
      }
    ]
  })
}

# Create ECS Task Role (for X-Ray write access)
resource "aws_iam_role" "ecs_xray_task_role" {
  name = "${var.name_prefix}-ecs-xray-taskrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
          }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xray_write_access" {
  role       = aws_iam_role.ecs_xray_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

#####################secrets component######################
## secrets iam roles
resource "aws_iam_role_policy" "ecs_secrets_access" {
  name = "ecs_secrets-access"
  role = aws_iam_role.ecs_xray_task_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"
        ],
      Resource = [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.mongodb_name}${var.mongodb_prefix}"
        ]  #[data.aws_secretsmanager_secret.mongodb_uri.arn] 
    },
    {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        Resource = "*"
      }
    ]
  })
}

## Add ECR read for task role if needed
resource "aws_iam_role_policy_attachment" "ecs_secrets_access" {
  role       = aws_iam_role.ecs_xray_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

## Deepseek addition
resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "ecs_execution_secrets"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.mongodb_name}${var.mongodb_prefix}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}