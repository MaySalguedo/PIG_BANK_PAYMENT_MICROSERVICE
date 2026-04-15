output "api_base_url" {
  value       = aws_api_gateway_stage.payment_stage.invoke_url
  description = "URL base del API Gateway de Pagos"
}