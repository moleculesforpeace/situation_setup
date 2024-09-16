resource "aws_iam_role" "cspm" {
  name = "CloudSecurityPostureManagement"
  path = "/situation/"
  managed_policy_arns = concat(
    [
      "arn:aws:iam::aws:policy/SecurityAudit",
      "arn:aws:iam::aws:policy/AWSSSOReadOnly",
      "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
      "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess",
    ],
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
