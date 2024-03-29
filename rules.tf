resource "aws_networkfirewall_firewall_policy" "main" {
  name = local.dashed_name

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    dynamic "stateful_rule_group_reference" {
      for_each = aws_networkfirewall_rule_group.allow-ips

      content {
        resource_arn = stateful_rule_group_reference.value.arn
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = aws_networkfirewall_rule_group.block-ips

      content {
        resource_arn = stateful_rule_group_reference.value.arn
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = aws_networkfirewall_rule_group.block-domains

      content {
        resource_arn = stateful_rule_group_reference.value.arn
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = aws_networkfirewall_rule_group.block-everything

      content {
        resource_arn = stateful_rule_group_reference.value.arn
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "allow-ips" {
  for_each = var.allowed_ips

  capacity    = each.value.capacity
  description = format("%s allow specific IPs for %s", local.dashed_name, each.key)
  name        = format("%s-allow-specific-ips-%s", local.dashed_name, each.key)
  type        = "STATEFUL"

  rule_group {
    rules_source {

      dynamic "stateful_rule" {
        for_each = each.value.ips

        content {
          action = "PASS"
          header {
            destination      = "ANY"
            destination_port = "ANY"
            protocol         = "IP"
            direction        = "ANY"
            source_port      = "ANY"
            source           = stateful_rule.value
          }
          rule_option {
            keyword = "sid:1${each.key}${stateful_rule.key}"
          }
        }
      }

      dynamic "stateful_rule" {
        for_each = each.value.ips

        content {
          action = "PASS"
          header {
            destination      = stateful_rule.value
            destination_port = "ANY"
            protocol         = "IP"
            direction        = "ANY"
            source_port      = "ANY"
            source           = "ANY"
          }
          rule_option {
            keyword = "sid:0${each.key}${stateful_rule.key}"
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "block-ips" {
  for_each = var.blocked_ips

  capacity    = each.value.capacity
  description = format("%s block specific IPs for %s", local.dashed_name, each.key)
  name        = format("%s-block-specific-ips-%s", local.dashed_name, each.key)
  type        = "STATEFUL"

  rules = join("\n", [for ip in each.value.ips : "drop IP $HOME_NET ANY <> ${ip} ANY (sid:0${each.key}${index(each.value.ips, ip)};)"])

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "block-domains" {
  for_each = var.blocked_domains

  capacity    = each.value.capacity
  description = format("%s block specific Domains for %s", local.dashed_name, each.key)
  name        = format("%s-block-specific-domains-%s", local.dashed_name, each.key)
  type        = "STATEFUL"

  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        targets              = each.value.domains
        target_types         = ["HTTP_HOST", "TLS_SNI"]
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "block-everything" {
  count = var.enable_block_everything_by_default == true ? 1 : 0

  capacity    = var.block_everything_capacity
  description = "Block all traffic"
  name        = format("%s-block-everything", local.dashed_name)
  type        = "STATEFUL"

  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          protocol         = "IP"
          direction        = "ANY"
          source_port      = "ANY"
          source           = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }

  tags = var.tags
}
