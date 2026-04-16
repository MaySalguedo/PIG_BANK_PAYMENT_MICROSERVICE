# 1. Obtener la tabla de rutas principal (Main) de la VPC
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
  
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# 2. Crear el Gateway Endpoint para S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [data.aws_route_table.default.id]
}