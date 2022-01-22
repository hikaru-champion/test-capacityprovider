##################################
# S3 Configure
##################################
resource "aws_s3_bucket" "test-ecs-bucket-source" {
  bucket = "test-ecs-bucket-source"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "test-ecs-bucket-artifact" {
  bucket        = "test-ecs-bucket-artifact"
  acl           = "private"
  force_destroy = true
}