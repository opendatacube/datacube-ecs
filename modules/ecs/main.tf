
resource "aws_ecs_task_definition" "datacube-service-task" {
  family = "${var.family}"
  container_definitions = <<EOF
  [
    {
    "name": "${var.container_name}",
    "image": "${var.container}",
    "memory": ${var.memory},
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.container_port}
      }
    ],
    "mountPoints": [
      {
        "containerPath": "${var.container_path}",
        "sourceVolume": "${var.volume_name}"
      }
    ],
    "environment": [
      { "name": "DB_USERNAME", "value": "master" },
      { "name": "DB_PASSWORD", "value": "${var.db_admin_password}" },
      { "name": "DB_DATABASE", "value": "datacube" },
      { "name": "DB_HOSTNAME", "value": "database.local" },
      { "name": "DB_PORT", "value": "5432" },
      { "name": "PUBLIC_URL", "value": "${var.public_url}"}
    ]
  }
]
EOF
  task_role_arn = "${var.task_role_arn}"
  volume {
    name = "${var.volume_name}",
    host_path = "${var.container_path}"
  }
}


resource "aws_ecs_service" "datacube-service" {
  name = "${var.name}"
  cluster = "${var.cluster}"
  task_definition = "${aws_ecs_task_definition.datacube-service-task.arn}"
  desired_count = "${var.desired_count}"
  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name = "${var.container_name}"
    container_port = "${var.container_port}"
  }
}