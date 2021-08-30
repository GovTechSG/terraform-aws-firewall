locals {
  account_id = data.aws_caller_identity.current.account_id

  dashed_name = replace(var.name, "/\\W|_|\\s/", "-")
}

data "aws_caller_identity" "current" {}

resource "random_id" "sid" {
  byte_length = 4
}

resource "aws_networkfirewall_firewall" "main" {
  count               = var.create_network_firewall ? 1 : 0
  name                = local.dashed_name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_logging_configuration" "main" {
  count = var.create_network_firewall ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.main[0].arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.main[0].name
      }

      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

resource "aws_cloudwatch_log_group" "main" {
  count = var.create_network_firewall ? 1 : 0
  name  = "${local.dashed_name}-fw-cwl"

  kms_key_id        = aws_kms_key.main[0].arn
  retention_in_days = var.cloudwatch_log_retention_in_days

  tags = var.tags
}

resource "aws_kms_key" "main" {
  count       = var.create_network_firewall ? 1 : 0
  description = "${local.dashed_name}-fw-cwl"

  enable_key_rotation     = true
  deletion_window_in_days = 14

  policy = <<EOF
  {
 "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*",
      "Condition": {
        "ArnEquals": {
            "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:${local.dashed_name}-fw-cwl"
        }
      }
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_kms_alias" "main" {
  count         = var.create_network_firewall ? 1 : 0
  name          = "alias/${local.dashed_name}-fw-cwl"
  target_key_id = aws_kms_key.main[0].key_id
}
