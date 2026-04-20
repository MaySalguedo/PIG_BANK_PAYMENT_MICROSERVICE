# --- DATA SOURCES ---
data "aws_region" "current" {}

# --- ROLES ---
resource "aws_iam_role" "payment_lambda_role" {
  name = "pig_bank_payment_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# --- ATTACHMENTS ---
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.payment_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# --- POLÍTICA S3 (CATÁLOGO) ---
resource "aws_iam_policy" "lambda_s3_policy" {
  name = "pig_bank_lambda_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Effect   = "Allow"
      Resource = [aws_s3_bucket.catalog_uploads.arn, "${aws_s3_bucket.catalog_uploads.arn}/*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.payment_lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

# --- POLÍTICA DYNAMODB (PAGOS) ---
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "pig_bank_lambda_dynamodb_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem", "dynamodb:Query"]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/payment-table"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.payment_lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# --- POLÍTICA SQS ACTUALIZADA (CONSUMIDOR Y PRODUCTOR) ---
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "pig_bank_lambda_sqs_policy"
  description = "Permite a las lambdas producir y consumir mensajes de la cola de pagos"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pig-bank-payment-notifications"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_sqs_policy" {
  role       = aws_iam_role.payment_lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}