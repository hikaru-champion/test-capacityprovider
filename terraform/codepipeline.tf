resource "aws_codepipeline" "this" {
  name     = "test-ecs-codepipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.test-ecs-bucket-artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      run_order        = 1
      name             = "Source"
      #namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        S3Bucket             = "test-ecs-bucket-source"
        S3ObjectKey          = "test.zip"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      #namespace        = "BuildVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.test_ecs_codebuild.name
      }
    }
  }

/*   stage {
    name = "Approval"
    action {
      category  = "Approval"
      name      = "DeployApproval"
      owner     = "AWS"
      provider  = "Manual"
      region    = var.aws_region
      run_order = 1
      version   = "1"
    }
  } */

  stage {
    name = "Deploy"

    action {
      name      = "Deploy01"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "CodeDeployToECS"
      region    = "ap-northeast-1"
      run_order = 1
      version   = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.ecs_codedeploy_app.name
        DeploymentGroupName            = "test-ecs-codedeploygroup01"
        TaskDefinitionTemplateArtifact = "BuildArtifact"
        TaskDefinitionTemplatePath     = "stg01/nginx01-taskdef.json"
        AppSpecTemplateArtifact        = "BuildArtifact"
        AppSpecTemplatePath            = "nginx01-appspec.yaml"
#        Image1ArtifactName             = "BuildArtifact"
#        Image1ContainerName            = "IMAGE1_NAME"
      }

      input_artifacts = [
        "BuildArtifact",
      ]
    }

    action {
      name      = "Deploy02"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "CodeDeployToECS"
      region    = "ap-northeast-1"
      run_order = 2
      version   = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.ecs_codedeploy_app.name
        DeploymentGroupName            = "test-ecs-codedeploygroup02"
        TaskDefinitionTemplateArtifact = "BuildArtifact"
        TaskDefinitionTemplatePath     = "stg01/nginx02-taskdef.json"
        AppSpecTemplateArtifact        = "BuildArtifact"
        AppSpecTemplatePath            = "nginx02-appspec.yaml"
#        Image1ArtifactName             = "BuildArtifact"
#        Image1ContainerName            = "IMAGE1_NAME"
      }

      input_artifacts = [
        "BuildArtifact",
      ]
    }

  }
}