### KMS key used in ap-southeast-1
resource "aws_kms_key" "s3_artifacts" {
  description             = "crossAccountPipelineKey"
  deletion_window_in_days = 10

  policy = data.aws_iam_policy_document.kms_policy.json
}

resource "aws_kms_alias" "alias_artifacts" {
  name          = "alias/crossAccountPipeline"
  target_key_id = aws_kms_key.s3_artifacts.key_id
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = ["true"]
    }
  }
}

### KMS used in eu-central-1
resource "aws_kms_key" "eu_s3_artifacts" {
  provider                = aws.eu-central-1
  description             = "crossAccountPipelineKey"
  deletion_window_in_days = 10

  policy = data.aws_iam_policy_document.eu_kms_policy.json
}

resource "aws_kms_alias" "eu_alias_artifacts" {
  provider      = aws.eu-central-1
  name          = "alias/UScrossAccountPipeline"
  target_key_id = aws_kms_key.eu_s3_artifacts.key_id
}

data "aws_iam_policy_document" "eu_kms_policy" {
  provider = aws.eu-central-1
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.prod_account_id}:root",
        "arn:aws:iam::${var.test_account_id}:root"
      ]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = ["true"]
    }
  }
}