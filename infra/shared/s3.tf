# S3 bucket for CodePipeline Artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = substr("${local.stack_name}-codepipeline-s3", 0, 63)
  force_destroy = true
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

# S3 bucket for CodePipeline Artifacts in EU
resource "aws_s3_bucket" "eu_codepipeline_bucket" {
  provider = aws.eu-central-1
  bucket        = substr("${local.stack_name}-eu-codepipeline-s3", 0, 63)
  force_destroy = true
}

resource "aws_s3_bucket_acl" "eu_codepipeline_bucket_acl" {
  provider = aws.eu-central-1
  bucket = aws_s3_bucket.eu_codepipeline_bucket.id
  acl    = "private"
}