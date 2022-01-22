#######################################
# ECR Configure
#######################################
# nginx01
resource "aws_ecr_repository" "nginx01_image_repo" {
  name                 = "nginx01-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "nginx01_image_lifecycle_policy" {
  repository = aws_ecr_repository.nginx01_image_repo.name

  policy = <<EOF
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Expire last 30 release tagged images",
                "selection": {
                    "tagStatus": "tagged",
                    "tagPrefixList": ["release"],
                    "countType": "imageCountMoreThan",
                    "countNumber": 30
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
EOF
}

# nginx01
resource "aws_ecr_repository" "nginx02_image_repo" {
  name                 = "nginx02-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "nginx02_image_lifecycle_policy" {
  repository = aws_ecr_repository.nginx02_image_repo.name

  policy = <<EOF
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Expire last 30 release tagged images",
                "selection": {
                    "tagStatus": "tagged",
                    "tagPrefixList": ["release"],
                    "countType": "imageCountMoreThan",
                    "countNumber": 30
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
EOF
}