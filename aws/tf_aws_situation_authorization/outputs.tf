output "role_arn" {
  value       = aws_iam_role.cspm.arn
  description = "ARN of CSPM IAM Role."
}
