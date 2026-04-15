provider "aws" {
  region = "us-east-1"
}

module "pig_bank_payment_infrastructure" {
  source               = "./terraform"
  lambda_zip_path      = "${path.module}/lambda.zip"
  card_service_api_url = var.card_service_api_url # Pasa la variable sensible
}

variable "card_service_api_url" {
  type        = string
  description = "URL del microservicio de tarjetas"
}

output "payment_api_url" {
  value = module.pig_bank_payment_infrastructure.api_base_url
}