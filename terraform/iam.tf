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
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}