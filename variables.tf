variable "aws_region" {
  description = "Region which resources will be created in"
  type        = string
  default     = "ap-southeast-1"
}

variable "create_network_firewall" {
  description = "toggle for creation of network firewall, set to false if you only want to create the firewall policy with this module"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the network firewall"
  type        = string
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  description = "Subnets used to create network firewall."
  type        = set(string)
  default     = []
}

# misc
variable "tags" {
  type        = map(any)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "allowed_ips" {
  description = "IPs to allow (both ingress & egress), note that keys can only be numeric."
  type        = map(list(string))
  default     = {}
}

# allow ips/domains - egress (outgoing)
variable "egress_allowed_ips" {
  description = "Destination IPs to allow for outgoing, note that keys can only be numeric."
  type        = map(list(string))
  default     = {}
}

variable "blocked_ips" {
  description = "Block all traffic from/to specific IPs, note that keys can only be numeric."
  type        = map(list(string))
  default     = {}
}

variable "blocked_domains" {
  description = "Domains to block (both ingress & egress)"
  type        = map(set(string))
  default     = {}
}

variable "enable_block_everything_by_default" {
  description = "Creates rule that will block all traffic by default, and you will have to whitelist routes specifically to allow internet traffic"
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 90
}