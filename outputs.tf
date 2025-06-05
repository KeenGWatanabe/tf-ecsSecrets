output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "service_url" {
  value = aws_lb.app.dns_name
}