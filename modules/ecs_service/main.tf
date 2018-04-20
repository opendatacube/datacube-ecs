
resource "aws_ecs_task_definition" "service-task" {
  family = "${var.family}"
  container_definitions = "${var.container_definitions}"
  task_role_arn = "${var.task_role_arn}"
  # cpu = "${var.cpu}"
  # memory = "${var.memory}"
  # requires_compatibilities = "${var.launch_type}"
  volume {
    name = "${var.volume_name}",
    host_path = "${var.container_path}"
  }
}


resource "aws_ecs_service" "service" {
  name = "${var.name}"
  cluster = "${var.cluster}"
  task_definition = "${aws_ecs_task_definition.service-task.arn}"
  desired_count = "${var.desired_count}"
  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name = "${var.container_name}"
    container_port = "${var.container_port}"
  }
}
