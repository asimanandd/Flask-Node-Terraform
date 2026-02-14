provider "aws" {
  region = var.region
}

# ECR Repository - Backend
resource "aws_ecr_repository" "backend_repo" {
  name = "flask-backend-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "backend-ecr"
  }
}

# ECR Repository - Frontend
resource "aws_ecr_repository" "frontend_repo" {
  name = "node-frontend-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "frontend-ecr"
  }
}
