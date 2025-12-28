# Create ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
    name = "fullstack-user-ecs-cluster"
    tags = {
        Name = "Fullstack User ECS Cluster"
    }
}

# Create ECS Task Execution Role
resource "aws_iam_role" "task_execution_role" {
    name = "fullstack-user-ecs-task-execution-role"
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

# Create ECS Task Execution Policy
resource "aws_iam_policy" "task_execution_policy" {
    name = "fullstack-user-ecs-task-execution-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                # ECR and CloudWatch permissions
                Action = [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:GetRepositoryPolicy",
                    "ecr:DescribeRepositories",
                    "ecr:ListImages",
                    "ecr:DescribeImages",
                    "ecr:BatchGetImage",
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Effect = "Allow"
                Resource = "*"
            },
            {
                # Secrets Manager - restricted to specific secret
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret"
                ],
                Effect = "Allow"
                Resource = var.db_secret_arn
            }
        ]
    })
}

# Create ECS Task Execution Role Attachment
resource "aws_iam_role_policy_attachment" "task_execution_role_policy_attachment" {
    role = aws_iam_role.task_execution_role.name
    policy_arn = aws_iam_policy.task_execution_policy.arn
}

# Create ECS Task Role
resource "aws_iam_role" "task_role" {
    name = "fullstack-user-ecs-task-role"
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

# Create ECS Task Role Policy
resource "aws_iam_policy" "ecs_task_role_policy" {
    name = "fullstack-user-ecs-task-role-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:GetRepositoryPolicy",
                    "ecr:DescribeRepositories",
                    "ecr:ListImages",
                    "ecr:DescribeImages",
                    "ecr:BatchGetImage",
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "secretsmanager:GetSecretValue"
                ],
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

# Create ECS Task Role Attachment
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
    role = aws_iam_role.task_role.name
    policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

# Frontend
resource "aws_cloudwatch_log_group" "frontend_log_group" {
    name = "ecs/ecs/frontend-log-group"
    retention_in_days = 7
}

# Create Frontend Task Definition
resource "aws_ecs_task_definition" "frontend_task_definition" {
    family = "frontend-task-definition"
    execution_role_arn = aws_iam_role.task_execution_role.arn
    task_role_arn = aws_iam_role.task_role.arn
    network_mode = "awsvpc"
    cpu = "512"
    memory = "1024"
    requires_compatibilities = ["FARGATE"]

    container_definitions = jsonencode([
        {
            name = "frontend-container"
            image = "${var.frontend_ecr_image_url}:latest"
            essential = true
            environment = [
                {
                    name = "VUE_APP_API_URL"
                    value = "${var.alb_dns}"
                }
            ]
            portMappings = [
                {
                    containerPort = 80
                    protocol = "tcp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = aws_cloudwatch_log_group.frontend_log_group.name
                    "awslogs-region" = var.region
                    "awslogs-stream-prefix" = "frontend"
                }
            }
        }
    ])
}

resource "aws_ecs_service" "frontend_service" {
    name = "frontend-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.frontend_task_definition.arn
    desired_count = 1
    launch_type = "FARGATE"
    
    network_configuration {
        subnets = var.ecs_subnet_ids
        security_groups = var.ecs_security_group_ids
        assign_public_ip = true
    }
    
    load_balancer {
        target_group_arn = var.frontend_target_group_arn
        container_name = "frontend-container"
        container_port = 80
    }
}

# Backend
resource "aws_cloudwatch_log_group" "backend_log_group" {
    name = "ecs/ecs/backend-log-group"
    retention_in_days = 7
}

# Create Backend Task Definition
resource "aws_ecs_task_definition" "backend_task_definition" {
    family = "backend-task-definition"
    execution_role_arn = aws_iam_role.task_execution_role.arn
    task_role_arn = aws_iam_role.task_role.arn
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "512"
    memory = "1024"

    container_definitions = jsonencode([
        {
            name = "backend-container"
            image = "${var.backend_ecr_image_url}"
            essential = true
            environment = [
                {
                    name = "ASPNETCORE_ENVIRONMENT"
                    value = "Development"
                },
                {
                    name = "ASPNETCORE_URLS"
                    value = "http://+:5000"
                },
                {
                    name = "DB_HOST"
                    value = var.db_endpoint
                },
                {
                    name = "DB_NAME"
                    value = var.db_name
                },
                {
                    name = "DB_USERNAME"
                    value = var.db_username
                }
            ]
            secrets = [
                {
                    name = "DB_PASSWORD"
                    valueFrom = "${var.db_secret_arn}:password::"
                }
            ]
            portMappings = [
                {
                    containerPort = 5000
                    protocol = "tcp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = aws_cloudwatch_log_group.backend_log_group.name
                    "awslogs-region" = var.region
                    "awslogs-stream-prefix" = "backend"
                }
            }
        }
    ])
}

resource "aws_ecs_service" "backend_service" {
    name = "backend-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.backend_task_definition.arn
    desired_count = 1
    launch_type = "FARGATE"
    
    network_configuration {
        subnets = var.ecs_subnet_ids
        security_groups = var.ecs_security_group_ids
        assign_public_ip = true
    }
    
    load_balancer {
        target_group_arn = var.backend_target_group_arn
        container_name = "backend-container"
        container_port = 5000
    }
}