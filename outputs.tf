output "firewall" {
  value = aws_networkfirewall_firewall.main
}

output "firewall_policy_arn" {
  value = aws_networkfirewall_firewall_policy.main.arn
}
