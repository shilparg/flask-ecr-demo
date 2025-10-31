provider "aws" {
  region = "us-east-1"
}

# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98c6f0a1b5b4f3b8b5b3e1e3e1e3e1e3"] # GitHub OIDC thumbprint
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_oidc_role" {
  name = "GITHUB_OIDC_ROLE"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:shilparg/flask_ecr_demo:*"
          }
        }
      }
    ]
  })
}

# Permissions for ECR + ECS
resource "aws_iam_role_policy" "github_oidc_permissions" {
  name = "GitHubOIDC_ECR_ECS"
  role = aws_iam_role.github_oidc_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:AssumeRoleWithWebIdentity",
          "ecr:*",
          "ecs:*",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}