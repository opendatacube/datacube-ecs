resource "aws_kms_key" "parameter_store_key" {
  # For operation with chamber, the parameter_store_key
  # should be imported to use here. Alternatively the exported
  # key_id could be used as an environment variable argument
  # to chamber on the ECS instances 
}

data "aws_iam_policy_document" "container_perms" {
  statement {
    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/${var.parameter_store_resource}",
    ]
  }

  statement {
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.account_id}:*",
    ]
  }

  statement {
    actions = [
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:Describe*",
      "kms:Decrypt",
    ]

    resources = [
      "${aws_kms_key.parameter_store_key.arn}",
    ]
  }

  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "access_to_ssm" {
  name   = "${var.workspace}_${var.name}_tf_access_to_ssm_exc"
  path   = "/"
  policy = "${data.aws_iam_policy_document.container_perms.json}"
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.workspace}_${var.name}_tf_odc_ecs_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy_attachment" "ssm_perms_to_odc_role" {
  name       = "${var.workspace}_${var.name}_attach_ssm_policy_to_odc_ecs"
  roles      = ["${aws_iam_role.instance_role.name}"]
  policy_arn = "${aws_iam_policy.access_to_ssm.id}"
}
