data "aws_iam_policy_document" "app_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "med-hipaa-app-role"
  assume_role_policy = data.aws_iam_policy_document.app_assume.json
}

data "aws_iam_policy_document" "app_inline" {
  statement {
    sid    = "S3DataAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::med-hipaa-phi-data/*"
    ]
  }

  statement {
    sid    = "DocumentDBConnect"
    effect = "Allow"
    actions = [
      "rds-db:connect"
    ]
    resources = ["arn:aws:rds-db:us-east-1:${var.account_id}:dbuser:*/appuser"]
  }
}

resource "aws_iam_policy" "app" {
  name   = "med-hipaa-app-policy"
  policy = data.aws_iam_policy_document.app_inline.json
}

resource "aws_iam_role_policy_attachment" "app_attach" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}

resource "aws_iam_instance_profile" "app" {
  name = "med-hipaa-app-instance-profile"
  role = aws_iam_role.app.name
}

resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = var.vpc_id
}
