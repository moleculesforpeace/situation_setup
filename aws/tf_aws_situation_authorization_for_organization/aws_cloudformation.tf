locals {
  situation_trusting_role_name = "SituationAudit"
}

data "aws_organizations_organization" "current" {}

resource "aws_cloudformation_stack_set" "situation_authorization" {
  name         = "SituationAuthorization"
  description  = "Authorizes Situation to perform security audit operations"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  operation_preferences {
    failure_tolerance_count = 0
    max_concurrent_count    = 10
    region_concurrency_type = "PARALLEL"
  }
  managed_execution {
    active = true
  }
  permission_model = "SERVICE_MANAGED"
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }
  call_as = "SELF"
  template_body = jsonencode({
    Resources = {
      iamRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          AssumeRolePolicyDocument = jsonencode({
            Version = "2012-10-17"
            Statement = [
              {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                  AWS = aws_iam_role.cspm.arn
                }
              },
            ]
          })
          RoleName           = local.situation_trusting_role_name
          Description        = "Authorizations for Situation to audit the AWS Account"
          ManagedPolicyArns  = local.required_policy_arns_for_situation
          MaxSessionDuration = 60 * 60 * 12
        }
      }
    }
  })
}

resource "aws_cloudformation_stack_set_instance" "all_accounts" {
  stack_set_name = aws_cloudformation_stack_set.situation_authorization.name
  deployment_targets {
    organizational_unit_ids = [data.aws_organizations_organization.current.roots[0].id]
  }
  retain_stack = false
  call_as      = "SELF"
  operation_preferences {
    failure_tolerance_count = 0
    max_concurrent_count    = 10
    concurrency_mode        = "STRICT_FAILURE_TOLERANCE"
  }
}
