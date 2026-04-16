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

resource "aws_iam_role_policy_attachment" "payment_lambda_admin" {
  role       = aws_iam_role.payment_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# 1. Definir la política para leer el bucket
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "pig_bank_lambda_s3_policy"
  description = "Permite a la lambda leer el archivo csv del bucket de catalogo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.catalog_uploads.arn,
          "${aws_s3_bucket.catalog_uploads.arn}/*"
        ]
      }
    ]
  })
}

# 2. Adjuntar la política al rol que ya tienes
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.payment_lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}