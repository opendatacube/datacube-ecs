resource "aws_ecs_task_definition" "service-task" {
  family                = "${var.family}"
  container_definitions = "${var.container_definitions}"
  task_role_arn         = "${aws_iam_role.task_role.arn}"

  volume {
    name      = "${var.volume_name}"
    host_path = "${var.container_path}"
  }
}

resource "aws_ecs_service" "service" {
  # only create if webservice is true
  count           = "${var.webservice}"
  name            = "${var.name}"
  cluster         = "${var.cluster}"
  task_definition = "${aws_ecs_task_definition.service-task.arn}"
  desired_count   = "${var.task_desired_count}"

  load_balancer {
    target_group_arn = "${element(var.target_group_arn,0)}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
}

resource "null_resource" "aws_ecs_task" {
  count = "${var.webservice ? 0 : 1}"

  triggers {
    timestamp = "${timestamp()}"
  }

  # If it isn't a webservice start a once-off task
  # Terraform doesn't have a run-task capability as it's a short term thing
  provisioner "local-exec" {
    command = "aws ecs run-task --cluster ${var.cluster} --task-definition ${aws_ecs_task_definition.service-task.arn}"
  }

  depends_on = [ "aws_iam_role.task_role" ]
}

resource "aws_iam_role" "task_role" {
  name = "${var.cluster}-${var.name}-task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com",
          "events.amazonaws.com"
        ]
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

resource "aws_iam_policy" "custom_policy" {
  count  = "${length(var.custom_policy) > 0 ? 1 : 0}"
  name   = "${var.cluster}_${var.workspace}_${var.name}_policy"
  path   = "/"
  policy = "${var.custom_policy}"
}

resource "aws_iam_policy_attachment" "custom_policy_to_odc_role" {
  count      = "${length(var.custom_policy) > 0 ? 1 : 0}"
  name       = "${var.workspace}_${var.name}_attach_ssm_policy_to_odc_ecs"
  roles      = ["${aws_iam_role.task_role.name}"]
  policy_arn = "${aws_iam_policy.custom_policy.id}"
}

data "aws_iam_policy_document" "scheduled_task" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["${aws_iam_role.task_role.arn}"]
  }
}

resource "aws_iam_policy" "scheduled_task" {
  name   = "${var.cluster}_${var.workspace}_${var.name}_s_policy"
  policy = "${data.aws_iam_policy_document.scheduled_task.json}"
}

resource "aws_iam_role_policy_attachment" "schedule_policy_role" {
  role       = "${aws_iam_role.task_role.name}"
  policy_arn = "${aws_iam_policy.scheduled_task.arn}"
}

resource "aws_cloudwatch_event_rule" "task" {
  name                = "${var.cluster}_${var.workspace}_${var.name}_task"
  count               = "${var.schedulable ? 1 : 0}"
  schedule_expression = "${var.schedule_expression}"
}

resource "aws_cloudwatch_event_target" "task" {
  count    = "${var.schedulable ? 1 : 0}"
  rule     = "${aws_cloudwatch_event_rule.task.name}"
  arn      = "${data.aws_ecs_cluster.cluster.arn}"
  role_arn = "${aws_iam_role.task_role.arn}"

  ecs_target {
    task_count          = "${var.task_desired_count}"
    task_definition_arn = "${aws_ecs_task_definition.service-task.arn}"
  }
}
