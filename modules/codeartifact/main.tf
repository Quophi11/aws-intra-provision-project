resource "aws_codeartifact_domain" "this" {
  domain = var.domain_name
}

resource "aws_codeartifact_repository" "this" {
  repository   = var.repository_name
  domain       = aws_codeartifact_domain.this.domain
  description  = var.repository_description

  upstream {
    repository_name = "maven-central-store"
  }
}

resource "aws_iam_user" "codeartifact_user" {
  name = "codeartifact-user"
}

resource "aws_iam_policy" "codeartifact_policy" {
  name        = "CodeArtifactFullAccessPolicy"
  description = "Policy for full access to CodeArtifact domain and repository."
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeartifact:*",
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "codeartifact_attach" {
  user       = aws_iam_user.codeartifact_user.name
  policy_arn = aws_iam_policy.codeartifact_policy.arn
}
