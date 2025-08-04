resource "aws_vpc" "competition_rds_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "competitionlist_rds_vpc"
  }
}

resource "aws_subnet" "competition_rds_public_subnet_a" {
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"
  vpc_id            = aws_vpc.competition_rds_vpc.id

  tags = {
    Name = "rds-public_subnet_a"
  }
}

resource "aws_subnet" "competition_rds_public_subnet_b" {
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2b"
  vpc_id            = aws_vpc.competition_rds_vpc.id

  tags = {
    Name = "rds_public_subnet_b"
  }
}

resource "aws_internet_gateway" "competition_rds_igw" {
  vpc_id = aws_vpc.competition_rds_vpc.id

  tags = {
    Name = "competition_rds_igw"
  }
}

resource "aws_route_table" "competition_rds_rt" {
  vpc_id = aws_vpc.competition_rds_vpc.id

  tags = {
    Name = "competition_rds_rt"
  }
}

resource "aws_route" "competition_rds_route" {
  route_table_id         = aws_route_table.competition_rds_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.competition_rds_igw.id
}

resource "aws_route_table_association" "competition_public_subnet_association_a" {
  subnet_id      = aws_subnet.competition_rds_public_subnet_a.id
  route_table_id = aws_route_table.competition_rds_rt.id
}

resource "aws_route_table_association" "competition_public_subnet_association_b" {
  subnet_id      = aws_subnet.competition_rds_public_subnet_b.id
  route_table_id = aws_route_table.competition_rds_rt.id
}

resource "aws_db_subnet_group" "competition_rds_subnet_group" {
  name       = "competition_rds_subnet_group"
  subnet_ids = [aws_subnet.competition_rds_public_subnet_a.id, aws_subnet.competition_rds_public_subnet_b.id]
}

resource "aws_ssm_parameter" "competition_rds_db_username" {
  name  = "competition_rds_db_username"
  type  = "String"
  value = "Joyadmin"
}

resource "random_password" "password" {
  length  = 10
  special = false
}

resource "aws_ssm_parameter" "competition_rds_db_password" {
  name  = "competition_rds_db_password"
  type  = "String"
  value = random_password.password.result
}

resource "aws_security_group" "competition_rds_security_group" {
  name        = "allow_traffic"
  description = "Allow inbound traffic and outbound"
  vpc_id      = aws_vpc.competition_rds_vpc.id
  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_rule" {
  security_group_id = aws_security_group.competition_rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "TCP"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_rule" {
  security_group_id = aws_security_group.competition_rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports,allow all types of ip-protocol
}

resource "aws_db_instance" "competition_rds_db" {
  allocated_storage    = 10
  db_name              = "competition_db"
  engine               = "postgres"
  engine_version       = "16.6"
  instance_class       = "db.r5.large"
  username             = aws_ssm_parameter.competition_rds_db_username.value
  password             = aws_ssm_parameter.competition_rds_db_password.value
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.competition_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.competition_rds_security_group.id]
}