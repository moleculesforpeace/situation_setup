locals {
  required_policy_arns_for_situation = [
    "arn:aws:iam::aws:policy/SecurityAudit",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess",
  ]
}

resource "aws_iam_policy" "assume_role_on_other_accounts_from_org" {
  name        = "AssumeRoleOnOrganizationAccounts"
  description = "Enables sts:AssumeRole on AWS Accounts from the same Organization"
  policy = jsonencode(
    {
      "Version" = "2012-10-17"
      "Statement" = [{
        "Sid"      = "AssumeRole"
        "Effect"   = "Allow"
        "Action"   = "sts:AssumeRole"
        "Resource" = "arn:aws:iam::*:role/${local.situation_trusting_role_name}"
        "Condition" = {
          "StringEquals" = {
            "aws:ResourceOrgID" = "$${aws:PrincipalOrgID}"
          }
        }
      }]
    }
  )
}

resource "aws_iam_role" "cspm" {
  name = "CloudSecurityPostureManagement"
  managed_policy_arns = concat(
    local.required_policy_arns_for_situation,
    [
      aws_iam_policy.assume_role_on_other_accounts_from_org.arn
    ]
  )
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "${var.aws_principal}"
        }
      },
    ]
  })
}
