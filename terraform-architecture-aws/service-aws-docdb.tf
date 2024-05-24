##### VPC si besoin #####
module "vpc" {
  source                    = "terraform-aws-modules/vpc/aws"
  version                   = "2.77.0"
  name                      = "vpc"
  cidr                      = "10.0.0.0/16"

  azs                       = ["eu-west-2a", "eu-west-2b"]
  public_subnets            = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets           = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway        = true
  single_nat_gateway        = true 
  skip_final_snapshot       = true
  public_subnet_tags = {
      Name = "public"
  }
  private_subnet_tags = {
      Name = "private"
  }
}

# 1/ SECURITY GROUP DocumentDB and MySQL
resource "aws_security_group" "db_sg" {
  name                        = "db_sg"
  description                 = "Security group for DocumentDB and MySQL"
  vpc_id                      = module.vpc.vpc_id

  ingress {
    from_port                 = 27017
    to_port                   = 27017
    protocol                  = "tcp"
    cidr_blocks               = ["10.0.0.0/16"]  # vérifier par rapport à notre network
  }
  ingress {
    from_port                 = 3306
    to_port                   = 3306
    protocol                  = "tcp"
    cidr_blocks               = ["10.0.0.0/16"]  # vérifier par rapport à notre network
  }
  egress {
    from_port                 = 0
    to_port                   = 0
    protocol                  = "-1"
    cidr_blocks               = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db-sg"
  }
}


            ####################
            ##      DOCDB     ##  
            ####################


# 2/ SUBNET DOCDB
resource "aws_docdb_subnet_group" "db_subnet_group" {
  name                        = "db_subnet_group"
  subnet_ids                  = module.vpc.private_subnets
  tags = {
    Name                      = "db_subnet_group"
  }
}


# 3/ DocumentDB Cluster
resource "aws_docdb_cluster" "db_cluster" {
  cluster_identifier        = "db-cluster"
  master_username           = "admin"          #A changer si besoin
  master_password           = "password"       #A changer
  engine                    = "db"
  engine_version            = "4.0.0"
  availability_zone         = ["eu-west-3a", "eu-west-3b"]
  backup_retention_period   = 5
  preferred_backup_window   = "07:00-09:00"
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.docdb_sg.id]
  port                      = 27017
  tags = {
      Name                  = "db-cluster"
  }
}


# 4/ Instance DocDB
resource "aws_docdb_cluster_instance" "db-instance" {
  identifier                  = "docdb-instance"
  cluster_identifier          = aws_docdb_cluster.db_cluster.id
  instance_class              = "db.t3.medium"   #A changer si besoin
  engine                      = "docdb"
  engine_version              = "4.0.0"
  allocated_storage           = 20
  publicly_accessible         = false
  apply_immediately           = true
  tags = {
    Name                      = "db-instance"
  }
}


            ####################
            ##      MySQL     ##  
            ####################

# 5/ SUBNETGROUP pour MySQL
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name                        = "mysql_subnet_group"
  subnet_ids                  = module.vpc.private_subnets
  tags = {
    Name = "mysql_subnet_group"
  }
}

# 6/ Instance RDS
resource "aws_db_instance" "mysql_instance" {
  identifier                  = "mysql-instance"
  allocated_storage           = 20
  engine                      = "mysql"
  engine_version              = "8.0.20"
  instance_class              = "db.t3.medium"   #A changer si besoin
  #custom_iam_instance_profile = "AWSRDSCustomInstanceProfile" # Instance profile is required for Custom for Oracle. See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-orcl.html#custom-setup-orcl.iam-vpc
  username                    = "admin"          #A changer si besoin
  password                    = "password"       #A changer
  parameter_group_name        = "default.mysql8.0"
  skip_final_snapshot         = true 
  db_subnet_group_name        = aws_db_subnet_group.mysql_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  publicly_accessible         = false
  tags = {
    Name = "mysql-instance"
  }
}


# OUTPUTS
output "docdb_endpoint" {
    value = aws_docdb_cluster.db_cluster.endpoint
}

output "docdb_reader_endpoint" {
    value = aws_docdb_cluster.db_cluster.reader_endpoint
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql_instance.endpoint
}
