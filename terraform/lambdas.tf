locals {
  payment_env = {
    CARD_SERVICE_URL 	= var.card_service_api_url
    PAYMENT_TABLE    	= aws_dynamodb_table.payment_table.name
    AWS_SQS_QUEUE_URL  	= aws_sqs_queue.payment_queue.url,
	REDIS_HOST         	= aws_elasticache_cluster.redis_cluster.cache_nodes[0].address
    REDIS_PORT         	= "6379"
  }
}

# 1. Lambda para iniciar el pago (API Gateway)
resource "aws_lambda_function" "start_payment" {
  function_name    = "start-payment-lambda"
  runtime          = "nodejs22.x"
  handler          = "dist/start-payment-lambda.handler"
  role             = aws_iam_role.payment_lambda_role.arn
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = local.payment_env
  }
}

# 2. Lambda para procesar la transacción (Trigger SQS)
resource "aws_lambda_function" "transaction_process" {
  function_name    = "transaction-lambda"
  runtime          = "nodejs22.x"
  handler          = "dist/transaction-lambda.handler"
  role             = aws_iam_role.payment_lambda_role.arn
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = local.payment_env
  }
}

# 3. Lambda para sincronizar el catálogo (Trigger S3)
resource "aws_lambda_function" "sync_catalog" {
  function_name    = "sync-catalog-lambda"
  runtime          = "nodejs22.x"
  handler          = "dist/sync-catalog-lambda.handler"
  role             = aws_iam_role.payment_lambda_role.arn
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  timeout = 60
  memory_size = 256
  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = local.payment_env
  }
}

# 4. Lambda para obtener el catálogo (API Gateway)
resource "aws_lambda_function" "get_catalog" {
  function_name    = "get-catalog-lambda"
  runtime          = "nodejs22.x"
  handler          = "dist/get-catalog-lambda.handler"
  role             = aws_iam_role.payment_lambda_role.arn
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  timeout = 20
  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = local.payment_env
  }
}

# 5.

resource "aws_lambda_function" "get_transaction_status" {
  function_name    = "get-transaction-status-lambda"
  runtime          = "nodejs22.x"
  handler          = "dist/get-transaction-status-lambda.handler"
  role             = aws_iam_role.payment_lambda_role.arn
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = local.payment_env
  }
}

resource "aws_lambda_function" "get_all_transactions" {
  function_name    = "get-all-transactions-lambda"
  runtime          = "nodejs22.x"
  handler          = "dist/get-all-transactions-lambda.handler"
  role             = aws_iam_role.payment_lambda_role.arn
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = local.payment_env
  }
}

resource "aws_lambda_permission" "apigw_status" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_transaction_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.payment_api.execution_arn}/*/*"
}