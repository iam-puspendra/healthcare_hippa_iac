output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "database_endpoint" {
  value = module.database.cluster_endpoint
}
