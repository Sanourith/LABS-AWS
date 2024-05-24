output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "documentdb_endpoint" {
  value = module.documentdb.endpoint
}
