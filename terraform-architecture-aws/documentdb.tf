resource "aws_docdb_cluster" "default" {
  cluster_identifier = "docdb-cluster"
  master_username    = "docdb"
  master_password    = "yourpassword"
  db_subnet_group_name = aws_docdb_subnet_group.default.name
}

resource "aws_docdb_subnet_group" "default" {
  name       = "docdb-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_docdb_cluster_instance" "default" {
  count              = 1
  identifier         = "docdb-instance"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = "db.r5.large"
}

output "endpoint" {
  value = aws_docdb_cluster.default.endpoint
}
