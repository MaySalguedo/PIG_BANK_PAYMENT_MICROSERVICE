resource "aws_sqs_queue" "payment_queue" {
  name = "pig-bank-payment-notifications"
}

# Trigger para que SQS active la Lambda de procesamiento
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.payment_queue.arn
  function_name    = aws_lambda_function.transaction_process.arn
  batch_size       = 1
}