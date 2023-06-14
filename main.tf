data "aws_caller_identity" "current" {}

resource "aws_iam_role" "nuke" {
  name               = "${var.prefix}-${var.environment}-nuke-role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "nuke" {
  name        = "${var.prefix}-${var.environment}-nuke-iam-policy"
  path        = "/"
  description = "AWS IAM Policy for nuke script"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "nuke" {
  role       = aws_iam_role.nuke.name
  policy_arn = aws_iam_policy.nuke.arn
}

resource "aws_lambda_function" "nuke" {
  image_uri     = "public.ecr.aws/m0m7e8y4/nuke:latest"
  package_type  = "Image"
  function_name = "${var.prefix}-${var.environment}-nuke"
  role          = aws_iam_role.nuke.arn
  handler       = "nuke.handler"
  runtime       = "provided.al2"
  architectures = ["arm64"]
  timeout       = 900

  environment {
    variables = {
      PREFIX=var.prefix
      ENVIRONMENT=var.environment
      REGIONS=join(",", var.regions)
      BLOCKLIST=join(",", var.account_blocklist)
      ACCOUNT_ID=data.aws_caller_identity.current.account_id
    }
  }

  depends_on = [aws_iam_role_policy_attachment.nuke]
}

// Resources to run the Lambda on a schedule
resource "aws_lambda_permission" "cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nuke.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda.arn
}

resource "aws_cloudwatch_event_rule" "lambda" {
  name                = "${var.prefix}-${var.environment}-nuke"
  schedule_expression = "cron(15 00 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  target_id = "${var.prefix}-${var.environment}-nuke"
  rule      = aws_cloudwatch_event_rule.lambda.name
  arn       = aws_lambda_function.nuke.arn
}