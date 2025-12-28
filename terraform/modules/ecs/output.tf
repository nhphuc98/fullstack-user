output "ecs_cluster_id" {
  value       = aws_ecs_cluster.ecs_cluster.id
  description = "ECS Cluster ID"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.ecs_cluster.name
  description = "ECS Cluster Name"
}

output "task_execution_role_arn" {
  value       = aws_iam_role.task_execution_role.arn
  description = "ECS Task Execution Role ARN"
}

output "task_role_arn" {
  value       = aws_iam_role.task_role.arn
  description = "ECS Task Role ARN"
}

output "frontend_service_name" {
  value       = aws_ecs_service.frontend_service.name
  description = "Frontend ECS Service Name"
}

output "backend_service_name" {
  value       = aws_ecs_service.backend_service.name
  description = "Backend ECS Service Name"
}

