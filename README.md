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

  # for log group subscriptions 
  lg_filters = {
    "gcsoc" = {
      naming_suffix   = "gcsoc-lg-filter"
      role_arn        = "arn:aws:iam::${get_aws_account_id()}:role/central-logging-cloudwatch-firehose-role"
      filter_pattern  = ""
      destination_arn = "arn:aws:firehose:${local.common_vars.region}:${get_aws_account_id()}:deliverystream/clm-central-logging-firehose"
      distribution    = "ByLogStream"
    }
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
| [aws_cloudwatch_log_subscription_filter.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | IPs to allow (both ingress & egress), note that keys can only be numeric, and maximum capacity across all rules is 30000 | <pre>map(object({<br>    capacity = number<br>    ips      = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region which resources will be created in | `string` | `"ap-southeast-1"` | no |
| <a name="input_block_everything_capacity"></a> [block\_everything\_capacity](#input\_block\_everything\_capacity) | Number of rules this rule group will contain | `number` | `25` | no |
| <a name="input_blocked_domains"></a> [blocked\_domains](#input\_blocked\_domains) | Domains to block (both ingress & egress), maximum capacity across all rules is 30000 | <pre>map(object({<br>    capacity = number<br>    domains  = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_blocked_ips"></a> [blocked\_ips](#input\_blocked\_ips) | Block all traffic from/to specific IPs, note that keys can only be numeric, and maximum capacity across all rules is 30000 | <pre>map(object({<br>    capacity = number<br>    ips      = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_cloudwatch_log_retention_in_days"></a> [cloudwatch\_log\_retention\_in\_days](#input\_cloudwatch\_log\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `180` | no |
| <a name="input_create_network_firewall"></a> [create\_network\_firewall](#input\_create\_network\_firewall) | toggle for creation of network firewall, set to false if you only want to create the firewall policy with this module | `bool` | `true` | no |
| <a name="input_egress_allowed_ips"></a> [egress\_allowed\_ips](#input\_egress\_allowed\_ips) | Destination IPs to allow for outgoing, note that keys can only be numeric, and maximum capacity across all rules is 30000 | <pre>map(object({<br>    capacity = number<br>    ips      = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_enable_block_everything_by_default"></a> [enable\_block\_everything\_by\_default](#input\_enable\_block\_everything\_by\_default) | Creates rule that will block all traffic by default, and you will have to whitelist routes specifically to allow internet traffic | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the network firewall | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets used to create network firewall. | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(any)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | `""` | no |
| <a name="input_delete_protection"></a> [delete\_protection](#input\_delete\_protection) | n/a | `bool` | true | no |
| <a name="input_lg_filters"></a> [lg\_filters](#input\_lg\_filters) | Log group filters to create for Network Firewall logs | <pre>map(object({<br> naming_suffix = string<br> role_arn = string<br> filter_pattern = string<br> destination_arn = string<br> distribution = string<br>}))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall"></a> [firewall](#output\_firewall) | n/a |
| <a name="output_firewall_policy_arn"></a> [firewall\_policy\_arn](#output\_firewall\_policy\_arn) | n/a |
