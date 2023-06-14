variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "regions" {
  description = "List of regions to nuke in (global is always chosen)"
  type        = list(string)
  default = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "eu-central-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "eu-north-1",
    "eu-south-1",
  ]
}

variable "account_blocklist" {
  description = "List of accounts to skip nuking"
  type        = list(string)
}