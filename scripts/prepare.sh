#!/bin/sh
set -euo pipefail

cat << EOF > config.yaml
---
regions:
  - "global"
EOF

for i in $REGIONS
do
    # call your procedure/other scripts here below
    echo "  - \"$i\"" >> config.yaml
done

cat << EOF >> config.yaml

account-blocklist:
EOF

for i in $BLOCKLIST
do
    # call your procedure/other scripts here below
    echo "  - \"$i\"" >> config.yaml
done

cat << EOF >> config.yaml

resource-types:
  excludes:
  - EC2DefaultSecurityGroupRule

accounts:
  $ACCOUNT_ID:
    presets:
      - control_tower
      - account
      - sso
      - saml
      - default_vpc
    filters:
      LambdaFunction:
        - "$PREFIX-$ENVIRONMENT-nuke"
      CloudWatchEventsRule:
        - "Rule: $PREFIX-$ENVIRONMENT-nuke"
      CloudWatchEventsTarget:
        - "Rule: $PREFIX-$ENVIRONMENT-nuke Target ID: $PREFIX-$ENVIRONMENT-nuke"
      IAMPolicy:
        - type: "regex"
          value: "arn:aws:iam::[[:digit:]]{12}:policy/$PREFIX-$ENVIRONMENT-nuke-iam-policy"
      IAMRole:
        - "$PREFIX-$ENVIRONMENT-nuke-role"
      IAMRolePolicyAttachment:
        - "$PREFIX-$ENVIRONMENT-nuke-role -> $PREFIX-$ENVIRONMENT-nuke-iam-policy"
      CloudWatchLogsLogGroup:
        - "/aws/lambda/$PREFIX-$ENVIRONMENT-nuke"
      OpsWorksUserProfile:
        - type: "glob"
          value: "arn:aws:sts::*:assumed-role/$PREFIX-$ENVIRONMENT-nuke-role/$PREFIX-$ENVIRONMENT-nuke"


presets:
  control_tower:
    filters:
      CloudTrailTrail:
        - type: "glob"
          value: "aws-controltower-*"
  account:
    filters:
      IAMRole:
        - "OrganizationAccountAccessRole"
      IAMRolePolicyAttachment:
        - "OrganizationAccountAccessRole -> AdministratorAccess"
  sso:
    filters:
      IAMSAMLProvider:
        - type: "regex"
          value: "AWSSSO_.*_DO_NOT_DELETE"
      IAMRole:
        - type: "glob"
          value: "AWSReservedSSO_*"
      IAMRolePolicyAttachment:
        - type: "glob"
          value: "AWSReservedSSO_*"
      IAMRolePolicy:
        - type: "glob"
          value: "AWSReservedSSO_*"
      OpsWorksUserProfile:
        - type: "glob"
          value: "arn:aws:sts::*:assumed-role/AWSReservedSSO_*"
  saml:
    filters:
      IAMSAMLProvider:
        - type: "glob"
          value: "*saml-provider/AzureAD"
      IAMRole:
        - "IdPLambdaExecutionRole"
        - "Azure-AD-PowerUser-Role"
        - "Azure-AD-Read-Only-Role"
        - "Azure-AD-DBA-Role"
        - "Azure-AD-Admin-Role"
        - "AWS_IAM_AAD_UpdateTask_CrossAccountRole"
        - "AWSCloudFormationStackSetExecutionRole"
      IAMPolicy:
        - type: "regex"
          value: "arn:aws:iam::[[:digit:]]{12}:policy/IdPLambdaExecutionPolicy"
        - type: "regex"
          value: "arn:aws:iam::[[:digit:]]{12}:policy/CloudFormationStackSetExecutionRolePolicies"
      IAMRolePolicyAttachment:
        - "IdPLambdaExecutionRole -> IdPLambdaExecutionPolicy"
        - "Azure-AD-Admin-Role -> AdministratorAccess"
        - "Azure-AD-DBA-Role -> DatabaseAdministrator"
        - "Azure-AD-PowerUser-Role -> PowerUserAccess"
        - "Azure-AD-Read-Only-Role -> ViewOnlyAccess"
        - "AWS_IAM_AAD_UpdateTask_CrossAccountRole -> IAMReadOnlyAccess"
        - "AWSCloudFormationStackSetExecutionRole -> IAMFullAccess"
        - "AWSCloudFormationStackSetExecutionRole -> AWSLambdaExecute"
        - "AWSCloudFormationStackSetExecutionRole -> CloudFormationStackSetExecutionRolePolicies"
      LambdaFunction:
        - "IdPLambda"
      CloudFormationStack:
        - "AzureADFederationCrossAccountRoles"
        - type: "glob"
          value: "StackSet-IdpAndSamlRolesForAzureAdFederatedLogin*"
  default_vpc:
    filters:
      EC2VPC:
        - property: IsDefault
          value: "true"
      EC2DHCPOption:
        - property: DefaultVPC
          value: "true"
      EC2Subnet:
        - property: DefaultVPC
          value: "true"
      EC2InternetGateway:
        - property: DefaultVPC
          value: "true"
      EC2RouteTable:
        - property: DefaultVPC
          value: "true"
      EC2InternetGatewayAttachment:
        - property: DefaultVPC
          value: "true"
EOF