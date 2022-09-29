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
  provider      = aws.eu-central-1
  bucket        = substr("${local.stack_name}-eu-codepipeline-s3", 0, 63)
  force_destroy = true
}

resource "aws_s3_bucket_acl" "eu_codepipeline_bucket_acl" {
  provider = aws.eu-central-1
  bucket   = aws_s3_bucket.eu_codepipeline_bucket.id
  acl      = "private"
}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_policy" "eu_artifacts" {
  provider = aws.eu-central-1
  bucket   = aws_s3_bucket.eu_codepipeline_bucket.id
  policy   = data.aws_iam_policy_document.eu_bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid     = "DenyUnEncryptedObjectUploads"
    effect  = "Deny"
    actions = ["s3:PutObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
    "${aws_s3_bucket.codepipeline_bucket.arn}/*", ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = ["aws:kms"]
    }
  }

  statement {
    sid     = "DenyInsecureConnections"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
    "${aws_s3_bucket.codepipeline_bucket.arn}/*", ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = ["false"]
    }
  }

  statement {
    sid    = "AllowOtherAccountsObjects"
    effect = "Allow"
    actions = ["s3:Get*",
    "s3:Put*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
    resources = [
    "${aws_s3_bucket.codepipeline_bucket.arn}/*", ]
  }

  statement {
    sid     = "AllowOtherAccountsList"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
    resources = [aws_s3_bucket.codepipeline_bucket.arn,
    ]
  }
}

data "aws_iam_policy_document" "eu_bucket_policy" {
  statement {
    sid     = "DenyUnEncryptedObjectUploads"
    effect  = "Deny"
    actions = ["s3:PutObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
    "${aws_s3_bucket.eu_codepipeline_bucket.arn}/*", ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = ["aws:kms"]
    }
  }

  statement {
    sid     = "DenyInsecureConnections"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
    "${aws_s3_bucket.eu_codepipeline_bucket.arn}/*", ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = ["false"]
    }
  }

  statement {
    sid    = "AllowOtherAccountsObjects"
    effect = "Allow"
    actions = ["s3:Get*",
    "s3:Put*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
    resources = [
    "${aws_s3_bucket.eu_codepipeline_bucket.arn}/*", ]
  }

  statement {
    sid     = "AllowOtherAccountsList"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
    resources = [
      aws_s3_bucket.eu_codepipeline_bucket.arn,
    ]
  }
}