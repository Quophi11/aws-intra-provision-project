output "domain_arn" {
  value = aws_codeartifact_domain.this.arn
}

output "repository_arn" {
  value = aws_codeartifact_repository.this.arn
}

output "codeartifact_user_arn" {
  value = aws_iam_user.codeartifact_user.arn
}
