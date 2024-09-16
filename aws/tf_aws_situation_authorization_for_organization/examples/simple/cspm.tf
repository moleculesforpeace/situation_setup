data "aws_caller_identity" "current" {}

module "cspm_role" {
  source = "../../"

  aws_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}
