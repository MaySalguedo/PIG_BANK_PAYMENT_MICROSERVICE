resource "aws_sqs_queue" "payment_queue" {
  name = "pig-bank-payment-notifications"
}