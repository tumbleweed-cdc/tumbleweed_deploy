resource "aws_ecs_cluster" "main" {
  name = "tumbleweed-cluster"
}

data "aws_ecs_task" "tumbleweed_app" {
  cluster = aws_ecs_cluster.main.id
  task    = aws_ecs_service.tumbleweed_app.task_definition
}

data "aws_network_interface" "tumbleweed_app" {
  count = length(aws_ecs_service.tumbleweed_app.network_configuration[0].network_interfaces)

  id = aws_ecs_service.tumbleweed_app.network_configuration[0].network_interfaces[count.index].network_interface_id
}

