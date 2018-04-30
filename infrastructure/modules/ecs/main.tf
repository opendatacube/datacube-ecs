resource "aws_ecs_task_definition" "service-task" {
  family                = "${var.family}"
  container_definitions = "${var.container_definitions}"
  task_role_arn         = "${aws_iam_role.task_role.arn}"

  # cpu = "${var.cpu}"
  # memory = "${var.memory}"
  # requires_compatibilities = "${var.launch_type}"
  volume {
    name      = "${var.volume_name}"
    host_path = "${var.container_path}"
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.name}"
  cluster         = "${var.cluster}"
  task_definition = "${aws_ecs_task_definition.service-task.arn}"
  desired_count   = "${var.task_desired_count}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
}

resource "aws_iam_role" "task_role" {
  name = "task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "secrets" {
  name        = "${var.cluster}-${var.name}-secrets"
  path        = "/"
  description = "My test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:DescribeParameters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "ssm:ListTagsForResource"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/${var.cluster}*",
        "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/${var.name}*"
      ]
    },
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "secrets" {
  name       = "${var.workspace}_${var.name}_attach_secrets"
  roles      = ["${aws_iam_role.task_role.name}"]
  policy_arn = "${aws_iam_policy.secrets.arn}"
}

resource "aws_iam_policy_attachment" "cw_logs" {
  name       = "${var.workspace}_${var.name}_attach_cw_logs"
  roles      = ["${aws_iam_role.task_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_cloudwatch_log_group" "cw_logs" {
  name = "${var.cluster}/${var.workspace}/${var.name}"

  tags {
    Environment = "${var.workspace}"
    Application = "${var.name}"
  }
}
