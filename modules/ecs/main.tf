
# The ALB for the cluster
module "alb" {
  source = "../../../terraform-ecs/modules/load_balancer"

  workspace         = "${var.workspace}"
  cluster           = "${var.cluster}"
  owner             = "${var.owner}"
  service_name      = "${var.name}"
  vpc_id            = "${var.vpc_id}"
  public_subnet_ids = "${var.public_subnet_ids}"
  alb_name          = "${var.alb_name}"
  container_port    = "${var.container_port}"
  health_check_path = "/health"
}


# The ECS Service module
module "ecs_service" {
  source = "../../../terraform-ecs/modules/ecs"

  name    = "${var.name}"
  cluster = "${var.cluster}"
  family  = "${var.name}-service-task"

  desired_count = "${var.task_desired_count}"

  task_role_arn    = "${module.ecs_policy.role_arn}"
  target_group_arn = "${module.alb.alb_target_group}"

  # // container def
  container_definitions = <<EOF
[
  {
  "name": "${var.name}",
  "image": "${var.docker_image}",
  "memory": ${var.memory},
  "essential": true,
  "portMappings": [
    {
      "containerPort": ${var.container_port}
    }
  ],
  "mountPoints": [
    {
      "containerPath": "/opt/data",
      "sourceVolume": "volume-0"
    }
  ],
  "environment": [
    { "name": "DB_USERNAME", "value": "${var.db_username}" },
    { "name": "DB_DATABASE", "value": "${var.database}" },
    { "name": "DB_HOSTNAME", "value": "${var.db_name}.${var.db_zone}" },
    { "name": "DB_PORT"    , "value": "5432" },
    { "name": "PUBLIC_URL" , "value": "${var.public_url}"}
  ]
}
]
EOF

}

module "ecs_policy" {
  source = "../../../terraform-ecs/modules/ecs_policy"

  task_role_name = "${var.name}-role"

  name = "${var.name}"

  account_id         = "${data.aws_caller_identity.current.account_id}"
  aws_region         = "${var.aws_region}"
  ec2_security_group = "${var.ec2_security_group}"

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"
}
