# output "tumbleweed_app_public_ip" {
#   value = aws_ecs_task_definition.tumbleweed_app[data.aws_ecs_task_definition.tumbleweed_app.task_arns[0]].network_interfaces[0].association[0].public_ip
# }

# Output the public IP of the first network interface
output "tumbleweed_app_public_ip" {
  value = data.aws_network_interface.tumbleweed_app[0].association[0].public_ip
}
