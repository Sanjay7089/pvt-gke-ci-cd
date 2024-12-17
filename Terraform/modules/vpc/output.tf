# Output for VPC details
output "vpc_names" {
  value       = [for vpc in module.vpcs : vpc.network_name]
}
