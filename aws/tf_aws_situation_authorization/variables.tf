variable "aws_principal" {
  description = "AWS Principal that the generated IAM Role should trust."
  type        = string
}

variable "organization_trusting_iam_role_name" {
  description = "IAM Role name of IAM Roles which trust the Management account from the AWS Organization."
  type        = string
  default     = "OrganizationAccountAccessRole"
}
