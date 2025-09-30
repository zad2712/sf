################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = try(aws_vpc.this[0].id, aws_default_vpc.this[0].id, "")
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.this[0].arn, aws_default_vpc.this[0].arn, "")
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.this[0].cidr_block, aws_default_vpc.this[0].cidr_block, "")
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = try(aws_vpc.this[0].default_security_group_id, aws_default_vpc.this[0].default_security_group_id, "")
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = try(aws_vpc.this[0].default_network_acl_id, aws_default_vpc.this[0].default_network_acl_id, "")
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = try(aws_vpc.this[0].default_route_table_id, aws_default_vpc.this[0].default_route_table_id, "")
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = try(aws_vpc.this[0].instance_tenancy, aws_default_vpc.this[0].instance_tenancy, "")
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = try(aws_vpc.this[0].enable_dns_support, aws_default_vpc.this[0].enable_dns_support, "")
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = try(aws_vpc.this[0].enable_dns_hostnames, aws_default_vpc.this[0].enable_dns_hostnames, "")
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = try(aws_vpc.this[0].main_route_table_id, aws_default_vpc.this[0].main_route_table_id, "")
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = try(aws_vpc.this[0].ipv6_association_id, aws_default_vpc.this[0].ipv6_association_id, "")
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = try(aws_vpc.this[0].ipv6_cidr_block, aws_default_vpc.this[0].ipv6_cidr_block, "")
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = compact(aws_vpc_ipv4_cidr_block_association.this[*].cidr_block)
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = try(aws_vpc.this[0].owner_id, aws_default_vpc.this[0].owner_id, "")
}

################################################################################
# DHCP Options Set
################################################################################

output "dhcp_options_id" {
  description = "The ID of the DHCP options"
  value       = try(aws_vpc_dhcp_options.this[0].id, "")
}

################################################################################
# Internet Gateway
################################################################################

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].id, "")
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].arn, "")
}

################################################################################
# Egress Only Internet Gateway
################################################################################

output "egress_only_internet_gateway_id" {
  description = "The ID of the egress only Internet Gateway"
  value       = try(aws_egress_only_internet_gateway.this[0].id, "")
}

################################################################################
# Public Subnets
################################################################################

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = compact(aws_subnet.public[*].cidr_block)
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.public[*].ipv6_cidr_block)
}

################################################################################
# Private Subnets
################################################################################

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = compact(aws_subnet.private[*].cidr_block)
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.private[*].ipv6_cidr_block)
}

################################################################################
# Database Subnets
################################################################################

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database[*].arn
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = compact(aws_subnet.database[*].cidr_block)
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.database[*].ipv6_cidr_block)
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = try(aws_db_subnet_group.database[0].id, "")
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value       = try(aws_db_subnet_group.database[0].name, "")
}

################################################################################
# Route Tables
################################################################################

output "public_route_table_ids" {
  description = "List of IDs of the public route tables"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = try(coalescelist(aws_route_table.database[*].id, aws_route_table.private[*].id), [])
}

################################################################################
# Route Table Associations
################################################################################

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = aws_route_table_association.public[*].id
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = aws_route_table_association.private[*].id
}

output "database_route_table_association_ids" {
  description = "List of IDs of the database route table association"
  value       = aws_route_table_association.database[*].id
}

################################################################################
# NAT Gateways
################################################################################

output "nat_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat[*].public_ip
}

output "natgw_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.this[*].id
}

################################################################################
# Elastic IPs
################################################################################

output "nat_eips" {
  description = "List of Elastic IP addresses for NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "nat_eip_allocation_ids" {
  description = "List of EIP allocation IDs for NAT Gateways"
  value       = aws_eip.nat[*].allocation_id
}

################################################################################
# VPC Endpoints
################################################################################

output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = try(aws_vpc_endpoint.s3[0].id, "")
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.s3[0].prefix_list_id, "")
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = try(aws_vpc_endpoint.dynamodb[0].id, "")
}

output "vpc_endpoint_dynamodb_pl_id" {
  description = "The prefix list for the DynamoDB VPC endpoint"
  value       = try(aws_vpc_endpoint.dynamodb[0].prefix_list_id, "")
}

################################################################################
# VPC Flow Log
################################################################################

output "vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = try(aws_flow_log.this[0].id, "")
}

output "vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Log"
  value       = local.create_vpc && var.enable_flow_log ? var.flow_log_destination_arn : ""
}

output "vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Log"
  value       = local.create_vpc && var.enable_flow_log ? var.flow_log_destination_type : ""
}

################################################################################
# Static values (arguments)
################################################################################

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

output "name" {
  description = "The name of the VPC specified as argument to this module"
  value       = var.name
}