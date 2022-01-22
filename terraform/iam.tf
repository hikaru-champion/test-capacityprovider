################################################
# IAM Role Configure
################################################
data "aws_iam_policy_document" "test_ec2_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "test_ecs_task_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "test_ecs_service_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "test_ecs_codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "test_ecs_codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "test_ecs_codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "test_ecs_instance_role" {
  name               = "test_ecs_instance_role"
  assume_role_policy = data.aws_iam_policy_document.test_ec2_instance_assume_role_policy.json
}

resource "aws_iam_role" "test_ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.test_ecs_task_execution_assume_role_policy.json
}

resource "aws_iam_role" "test_ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = data.aws_iam_policy_document.test_ecs_service_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "ecs_instance_role_attach" {
  name       = "test_ecs_instance_role_attach"
  roles      = [aws_iam_role.test_ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_attach" {
  name       = "test_ecs_task_execution_role_attach"
  roles      = [aws_iam_role.test_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy_attachment" "ecs_service_role_attach" {
  name       = "test_ecs_service_role_attach"
  roles      = [aws_iam_role.test_ecs_service_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_instance_profile" "test_ecs" {
  name = "test_ecs_instance_profile"
  path = "/"
  role = aws_iam_role.test_ecs_instance_role.name
}

resource "aws_iam_role" "codedeploy" {
  name               = "test-ecs-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.test_ecs_codedeploy_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.codedeploy.id
}

resource "aws_iam_role" "codebuild" {
  name               = "codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.test_ecs_codebuild_assume_role_policy.json
}

resource "aws_iam_policy" "codebuildpolicy" {
  name        = "codebuildpolicy"
  description = "A test policy"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "CloudWatchLogsPolicy",
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "*"
		},
		{
			"Sid": "CodeCommitPolicy",
			"Effect": "Allow",
			"Action": [
				"codecommit:GitPull"
			],
			"Resource": "*"
		},
		{
			"Sid": "S3GetObjectPolicy",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:GetObjectVersion"
			],
			"Resource": "*"
		},
		{
			"Sid": "S3PutObjectPolicy",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject"
			],
			"Resource": "*"
		},
		{
			"Sid": "ECRPullPolicy",
			"Effect": "Allow",
			"Action": [
				"ecr:BatchCheckLayerAvailability",
				"ecr:GetDownloadUrlForLayer",
				"ecr:BatchGetImage",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload",
				"ecr:PutImage"
			],
			"Resource": "*"
		},
		{
			"Sid": "ECRAuthPolicy",
			"Effect": "Allow",
			"Action": [
				"ecr:GetAuthorizationToken"
			],
			"Resource": "*"
		},
		{
			"Sid": "S3BucketIdentity",
			"Effect": "Allow",
			"Action": [
				"s3:GetBucketAcl",
				"s3:GetBucketLocation"
			],
			"Resource": "*"
		}
	]
}
EOF
}


resource "aws_iam_role_policy_attachment" "codebuild" {
  policy_arn = aws_iam_policy.codebuildpolicy.arn
  role       = aws_iam_role.codebuild.id
}

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.test_ecs_codepipeline_assume_role_policy.json
}

resource "aws_iam_policy" "codepipelinepolicy" {
  name        = "codepipelinepolicy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "ecs:DescribeServices",
                "ecs:DescribeTaskDefinition",
                "ecs:RegisterTaskDefinition",
                "ecs:UpdateService"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": "iam:PassRole",
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  policy_arn = aws_iam_policy.codepipelinepolicy.arn
  role       = aws_iam_role.codepipeline.id
}