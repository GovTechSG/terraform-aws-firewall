# terraform-aws-firewall
Terraform module to create an AWS firewall

## Usage

```hcl
module "firewall" {
  name        = "my-firewall"
  description = "my firewall for this vpc"

  # Cannot use vpc dependency as vpc will also depend on this
  subnet_ids = [
   "subnet-1a",
   "subnet-1b",
   "subnet-1c"
  ]

  vpc_id = "vpc-xx"

  # the key name will be used in sid, only accept numeric :*
  blocked_ips = {
    "30092021": [
      "277.333.444.555/32", "333.444.555.666/32"
    ]
  }

  blocked_domains = {
    "my-blocked-domain-list": [
      "example.com"
    ]
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_networkfirewall_firewall.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall) | resource |
| [aws_networkfirewall_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_logging_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration) | resource |
| [aws_networkfirewall_rule_group.allow-ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.block-domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.block-everything](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.block-ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [random_id.sid](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | IPs to allow (both ingress & egress), note that keys can only be numeric. | `map(list(string))` | `{}` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region which resources will be created in | `string` | `"ap-southeast-1"` | no |
| <a name="input_blocked_domains"></a> [blocked\_domains](#input\_blocked\_domains) | Domains to block (both ingress & egress) | `map(set(string))` | `{}` | no |
| <a name="input_blocked_ips"></a> [blocked\_ips](#input\_blocked\_ips) | Block all traffic from/to specific IPs, note that keys can only be numeric. | `map(list(string))` | `{}` | no |
| <a name="input_egress_allowed_ips"></a> [egress\_allowed\_ips](#input\_egress\_allowed\_ips) | Destination IPs to allow for outgoing, note that keys can only be numeric. | `map(list(string))` | `{}` | no |
| <a name="input_enable_block_everything_by_default"></a> [enable\_block\_everything\_by\_default](#input\_enable\_block\_everything\_by\_default) | Creates rule that will block all traffic by default, and you will have to whitelist routes specifically to allow internet traffic | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the network firewall | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets used to create network firewall. | `set(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(any)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall"></a> [firewall](#output\_firewall) | n/a |
