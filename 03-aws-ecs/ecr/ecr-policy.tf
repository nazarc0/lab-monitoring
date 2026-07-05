resource "aws_ecr_lifecycle_policy" "prometheus_policy" {
  repository = aws_ecr_repository.prometheus.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 3 images"
      selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 3 }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "alertmanager_policy" {
  repository = aws_ecr_repository.alertmanager.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 3 images"
      selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 3 }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "web_policy" {
  repository = aws_ecr_repository.web.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 3 images"
      selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 3 }
      action = { type = "expire" }
    }]
  })
}