# 1. Створюємо OIDC Провайдер для GitHub
# 1. Автоматично стягуємо актуальний сертифікат із GitHub
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# 2. Створюємо OIDC Провайдер із динамічним відбитком
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  
  # Тепер Терраформ сам підставлятиме сюди правильний ключ
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
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
            "token.actions.githubusercontent.com:sub" = "repo:nazarc0/lab-monitoring:*"
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
        Resource = [
          module.ecr.prometheus_arn,
          module.ecr.alertmanager_arn,
          module.ecr.web_arn
        ]
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