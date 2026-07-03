# 1. Створюємо OIDC Провайдер для GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  
  # Офіційні thumbprints сертифікатів GitHub
  thumbprint_list = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd", 
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# 2. Роль для конвеєра з перевіркою репозиторію
resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsECRRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # УВАГА: ЗАМІНИ ТУТ ЛОГІН І НАЗВУ РЕПОЗИТОРІЮ НА СВОЇ
            "token.actions.githubusercontent.com:sub" = "repo:TVIY_GITHUB_LOGIN/lab-monitoring:*"
          }
        }
      }
    ]
  })
}

# 3. Політика доступу до ECR (Least Privilege)
resource "aws_iam_policy" "github_ecr_policy" {
  name        = "GitHubActionsECRPolicy"
  description = "Allow GitHub Actions to push images"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        # Посилаємося на репозиторій, створений у файлі ecr.tf
        Resource = aws_ecr_repository.lab_repo.arn 
      }
    ]
  })
}

# 4. Прикріплюємо політику до ролі
resource "aws_iam_role_policy_attachment" "github_ecr_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_ecr_policy.arn
}

# 5. ARN, який нам знадобиться для GitHub
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}