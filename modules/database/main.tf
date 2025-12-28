resource "aws_docdb_cluster" "cluster" {
  cluster_identifier      = "hipaa-docdb-cluster"
  engine                  = "docdb"
  master_username         = var.db_username
  master_password         = var.db_password
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
  backup_retention_period = 7
  skip_final_snapshot     = true
  tags = {
    Name = "hipaa-docdb-cluster"
  }
}

resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "hipaa-docdb-subnet-group"
  subnet_ids = var.private_db_subnet_ids
}

resource "aws_docdb_cluster_instance" "instance" {
  count              = var.instance_count
  cluster_identifier = aws_docdb_cluster.cluster.id
  instance_class     = "db.t4g.medium"
  identifier         = "hipaa-docdb-instance-${count.index}"
}