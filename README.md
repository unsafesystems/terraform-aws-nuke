# Terraform AWS Lambda NUKE

Resources to implement functionality to nuke an entire AWS account from a Lambda function based on
[aws-nuke](https://github.com/rebuy-de/aws-nuke). Filters are set in order to prevent:

- deletion of the nuke Lambda itself (and its roles, logs, etc.)
- deletion of any SAML, SSO, ControlTower resources

## Variables

| Name              | Description                               | Type           | Default            | Required |
|-------------------|-------------------------------------------|----------------|--------------------|:--------:|
| prefix            | Prefix to use for each resource name      | `string`       | none               |   yes    |
| environment       | Environment to use for each resource name | `string`       | none               |   yes    |
| regions           | List of regions to nuke                   | `list(string)` | see `variables.tf` |    no    |
| account_blocklist | List of account IDs to skip               | `list(string)` | none               |    no    |

## Names of the resources

All resources are named using the following convention:

```
Policy: "${var.prefix}-${var.environment}-nuke-iam-policy"
Role:   "${var.prefix}-${var.environment}-nuke-iam-role"
Lambda: "${var.prefix}-${var.environment}-nuke"

All other resources are named similarly.
```

