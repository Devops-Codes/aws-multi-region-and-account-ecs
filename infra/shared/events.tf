resource "aws_cloudwatch_event_rule" "pipeline_trigger" {
  name        = "${local.stack_name}-pipeline-trigger"
  description = "CodePipeline Trigger"

  event_pattern = <<PATTERN
{
    "source": [
        "aws.codecommit"
    ],
    "detail-type": [
        "CodeCommit Repository State Change"
    ],
    "resources": [
        "${aws_codecommit_repository.backend.arn}"
    ],
    "detail": {
        "event": [
            "referenceCreated",
            "referenceUpdated"
        ],
        "referenceType": [
            "branch"
        ],
        "referenceName": [
            "${var.default_backend_branch}"
        ]
    }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "pipeline_trigger" {
  target_id = "codepipeline"
  role_arn  = aws_iam_role.codepipeline_trigger.arn
  rule      = aws_cloudwatch_event_rule.pipeline_trigger.name
  arn       = aws_codepipeline.backend_pipeline.arn
}
