/**********************************************************
 * Define local variables
 **********************************************************/

locals {
  prefix      = var.prefix != "" ? "${var.prefix}-" : ""
  cron_name   = "${local.prefix}${var.cron_name}"
  role_name   = "${local.cron_name}-invoke-role"
  policy_name = "${local.cron_name}-policy"
}

/**********************************************************
 * Cloudwatch cron job
 **********************************************************/

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = local.cron_name
  schedule_expression = var.cron_expression
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule     = aws_cloudwatch_event_rule.event_rule.id
  arn      = var.state_machine_id
  role_arn = aws_iam_role.role.arn
}

/**********************************************************
 * Permission for cloudwatch cron job
 **********************************************************/

resource "aws_iam_role" "role" {
  name               = local.role_name
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": [
              "states.amazonaws.com",
              "events.amazonaws.com"
            ]
          }
        }
      ]
    }
  EOF
}

resource "aws_iam_role_policy" "policy" {
  name = local.policy_name
  role = aws_iam_role.role.id

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "states:StartExecution"
          ],
          "Resource": [
            "${var.state_machine_arn}"
          ]
        }
      ]
    }
  EOF
}
