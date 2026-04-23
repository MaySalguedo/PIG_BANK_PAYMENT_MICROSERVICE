resource "aws_api_gateway_rest_api" "payment_api" {
  name        = "pig-bank-payment-api"
  description = "API para el procesamiento de pagos y gestión de catálogo"
}

# --- Recurso /payments ---
resource "aws_api_gateway_resource" "payments" {
  rest_api_id = aws_api_gateway_rest_api.payment_api.id
  parent_id   = aws_api_gateway_rest_api.payment_api.root_resource_id
  path_part   = "payments"
}

resource "aws_api_gateway_method" "post_payment" {
  rest_api_id   = aws_api_gateway_rest_api.payment_api.id
  resource_id   = aws_api_gateway_resource.payments.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_all_transactions" {
  rest_api_id   = aws_api_gateway_rest_api.payment_api.id
  resource_id   = aws_api_gateway_resource.payments.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "int_start_payment" {
  rest_api_id             = aws_api_gateway_rest_api.payment_api.id
  resource_id             = aws_api_gateway_resource.payments.id
  http_method             = aws_api_gateway_method.post_payment.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.start_payment.invoke_arn
}

resource "aws_api_gateway_integration" "int_get_all_transactions" {
  rest_api_id             = aws_api_gateway_rest_api.payment_api.id
  resource_id             = aws_api_gateway_resource.payments.id
  http_method             = aws_api_gateway_method.get_all_transactions.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_all_transactions.invoke_arn
}

# /payments/{traceId}
resource "aws_api_gateway_resource" "payment_status" {
  rest_api_id = aws_api_gateway_rest_api.payment_api.id
  parent_id   = aws_api_gateway_resource.payments.id
  path_part   = "{traceId}"
}

resource "aws_api_gateway_method" "get_status" {
  rest_api_id   = aws_api_gateway_rest_api.payment_api.id
  resource_id   = aws_api_gateway_resource.payment_status.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "int_get_status" {
  rest_api_id             = aws_api_gateway_rest_api.payment_api.id
  resource_id             = aws_api_gateway_resource.payment_status.id
  http_method             = aws_api_gateway_method.get_status.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_transaction_status.invoke_arn
}

# --- Recurso /catalog/sync ---
resource "aws_api_gateway_resource" "catalog" {
  rest_api_id = aws_api_gateway_rest_api.payment_api.id
  parent_id   = aws_api_gateway_rest_api.payment_api.root_resource_id
  path_part   = "catalog"
}

resource "aws_api_gateway_resource" "catalog_sync" {
  rest_api_id = aws_api_gateway_rest_api.payment_api.id
  parent_id   = aws_api_gateway_resource.catalog.id
  path_part   = "sync"
}

resource "aws_api_gateway_method" "post_sync" {
  rest_api_id   = aws_api_gateway_rest_api.payment_api.id
  resource_id   = aws_api_gateway_resource.catalog_sync.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "int_sync_catalog" {
  rest_api_id             = aws_api_gateway_rest_api.payment_api.id
  resource_id             = aws_api_gateway_resource.catalog_sync.id
  http_method             = aws_api_gateway_method.post_sync.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.sync_catalog.invoke_arn
}

resource "aws_api_gateway_method" "get_catalog" {
  rest_api_id   = aws_api_gateway_rest_api.payment_api.id
  resource_id   = aws_api_gateway_resource.catalog.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "int_get_catalog" {
  rest_api_id             = aws_api_gateway_rest_api.payment_api.id
  resource_id             = aws_api_gateway_resource.catalog.id
  http_method             = aws_api_gateway_method.get_catalog.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_catalog.invoke_arn
}

resource "aws_lambda_permission" "apigw_get_catalog" {
  statement_id  = "AllowExecutionFromAPIGatewayGetCatalog"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_catalog.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.payment_api.execution_arn}/*/*"
}

# --- Despliegue y Stage ---
resource "aws_api_gateway_deployment" "payment_deployment" {
  depends_on = [
    aws_api_gateway_integration.int_start_payment,
    aws_api_gateway_integration.int_sync_catalog,
    aws_api_gateway_integration.int_get_catalog,
    aws_api_gateway_integration.int_get_status,
    aws_api_gateway_integration.int_get_all_transactions
  ]

  rest_api_id = aws_api_gateway_rest_api.payment_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.payments.id,
      aws_api_gateway_resource.payment_status.id,
      aws_api_gateway_resource.catalog.id,
      aws_api_gateway_resource.catalog_sync.id,
      aws_api_gateway_method.post_payment.id,
      aws_api_gateway_method.post_sync.id,
      aws_api_gateway_method.get_catalog.id,
      aws_api_gateway_method.get_status.id,
      aws_api_gateway_method.get_all_transactions.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "payment_stage" {
  deployment_id = aws_api_gateway_deployment.payment_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.payment_api.id
  stage_name    = "prod"
}

# --- Permisos para Lambdas ---
resource "aws_lambda_permission" "apigw_payment" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_payment.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.payment_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_sync" {
  statement_id  = "AllowExecutionFromAPIGatewaySync"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sync_catalog.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.payment_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_get_all" {
  statement_id  = "AllowAPIGatewayInvokeGetAll"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_transactions.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.payment_api.execution_arn}/*/GET/payments"
}