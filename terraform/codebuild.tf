resource "aws_cloudwatch_log_group" "codebuild" {
  name = "/codebuild/test-ecs-loggroup"
}

resource "aws_codebuild_project" "test_ecs_codebuild" {
  name          = "test-ecs-codebuild"
  description   = "CodeBuild Project for Test Ecs-Codebuild"
  build_timeout = 60
  service_role  = aws_iam_role.codebuild.arn

  source {
    type     = "S3"
    location = "test-ecs-bucket-source/test.zip"
    buildspec = "buildspec.yaml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "503497204644"
    }

    environment_variable {
      name  = "NGINX_IMAGE_REPO_NAME01"
      value = aws_ecr_repository.nginx01_image_repo.name
    }

    environment_variable {
      name  = "NGINX_IMAGE_REPO_NAME02"
      value = aws_ecr_repository.nginx02_image_repo.name
    }

    environment_variable {
      name  = "TASK_FAMILY01"
      value = "nginx01_task"
    }

    environment_variable {
      name  = "TASK_FAMILY02"
      value = "nginx02_task"
    }

    environment_variable {
      name  = "EXECUTION_ROLE_ARN"
      value = aws_iam_role.test_ecs_task_execution_role.arn
    }

    environment_variable {
      name  = "CONTAINER_NAME01"
      value = "nginx01-container"
    }

    environment_variable {
      name  = "CONTAINER_NAME02"
      value = "nginx02-container"
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = ""
    }
  }
}