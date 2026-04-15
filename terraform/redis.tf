# 1. Detectar la VPC por defecto de tu cuenta
data "aws_vpc" "default" {
  default = true
}

# 2. Detectar las subredes de esa VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. Grupo de subredes para Redis (Usando las subredes detectadas)
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "pig-bank-redis-subnets"
  subnet_ids = data.aws_subnets.default.ids
}

# 4. Grupo de seguridad para Redis
resource "aws_security_group" "redis_sg" {
  name   = "pig-bank-redis-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. El clúster de Redis
resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "pig-bank-catalog-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]
}