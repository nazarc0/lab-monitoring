resource "aws_ecr_repository" "prometheus" {
  name                 = "lab-monitoring-prometheus"
  image_tag_mutability = "MUTABLE" 

  force_delete = true 
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "alertmanager" {
  name                 = "lab-monitoring-alertmanager"
  image_tag_mutability = "MUTABLE" 

  force_delete = true 
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "web" {
  name                 = "lab-monitoring-web"
  image_tag_mutability = "MUTABLE" 

  force_delete = true 
  image_scanning_configuration {
    scan_on_push = true
  }
}