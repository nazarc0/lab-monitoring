resource "aws_ecr_repository" "lab_repo" {
  name                 = "lab-monitoring"
  image_tag_mutability = "MUTABLE" # Дозволяє перезаписувати теги для навчання

  force_delete = true # Цей параметр дуже допоможе під час Cleanup

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_lifecycle_policy" "lab_repo_policy" {
  repository = aws_ecr_repository.lab_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}