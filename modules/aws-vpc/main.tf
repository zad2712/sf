################################################################################
# Local Values
################################################################################

locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.database_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")

  create_vpc = length(var.cidr) > 0

  create_database_subnet_group    = var.create_database_subnet_group && length(var.database_subnets) > 0
  create_database_subnet_route_table = length(var.database_subnets) > 0
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block                           = var.cidr
  instance_tenancy                     = var.instance_tenancy
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = local.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  # Do not turn this into `local.vpc_id`
  vpc_id     = aws_vpc.this[0].id
  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

resource "aws_default_vpc" "this" {
  count = local.create_vpc ? 0 : 1

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
    var.vpc_tags,
  )
}

################################################################################
# DHCP Options Set
################################################################################

resource "aws_vpc_dhcp_options" "this" {
  count = local.create_vpc && var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
    var.dhcp_options_tags,
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = local.create_vpc && var.enable_dhcp_options ? 1 : 0

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = local.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
    var.igw_tags,
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  count = local.create_vpc && var.create_egress_only_igw && var.enable_ipv6 && local.max_subnet_length > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}

################################################################################
# Publiс Subnets
################################################################################

resource "aws_subnet" "public" {
  count = local.create_vpc && length(var.public_subnets) > 0 && (length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0

  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  enable_dns64                    = var.enable_ipv6 && var.enable_dns64 && var.public_subnet_enable_dns64
  enable_resource_name_dns_a_record_on_launch    = var.public_subnet_enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_ipv6 && var.public_subnet_enable_resource_name_dns_aaaa_record_on_launch
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null
  ipv6_native                     = var.enable_ipv6 && var.public_subnet_ipv6_native
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  private_dns_hostname_type_on_launch = var.public_subnet_private_dns_hostname_type_on_launch
  vpc_id                          = local.vpc_id

  tags = merge(
    {
      "Name" = try(
        var.public_subnet_names[count.index],
        format("${var.name}-${var.public_subnet_suffix}-%s", element(var.azs, count.index))
      )
    },
    var.tags,
    var.public_subnet_tags,
    lookup(var.public_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  count = local.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                      = element(concat(var.private_subnets, [""]), count.index)
  enable_dns64                    = var.enable_ipv6 && var.enable_dns64 && var.private_subnet_enable_dns64
  enable_resource_name_dns_a_record_on_launch    = var.private_subnet_enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_ipv6 && var.private_subnet_enable_resource_name_dns_aaaa_record_on_launch
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null
  ipv6_native                     = var.enable_ipv6 && var.private_subnet_ipv6_native
  private_dns_hostname_type_on_launch = var.private_subnet_private_dns_hostname_type_on_launch
  vpc_id                          = local.vpc_id

  tags = merge(
    {
      "Name" = try(
        var.private_subnet_names[count.index],
        format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index))
      )
    },
    var.tags,
    var.private_subnet_tags,
    lookup(var.private_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

################################################################################
# Database Subnets
################################################################################

resource "aws_subnet" "database" {
  count = local.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                      = element(concat(var.database_subnets, [""]), count.index)
  enable_dns64                    = var.enable_ipv6 && var.enable_dns64 && var.database_subnet_enable_dns64
  enable_resource_name_dns_a_record_on_launch    = var.database_subnet_enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_ipv6 && var.database_subnet_enable_resource_name_dns_aaaa_record_on_launch
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.database_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.database_subnet_ipv6_prefixes[count.index]) : null
  ipv6_native                     = var.enable_ipv6 && var.database_subnet_ipv6_native
  private_dns_hostname_type_on_launch = var.database_subnet_private_dns_hostname_type_on_launch
  vpc_id                          = local.vpc_id

  tags = merge(
    {
      "Name" = try(
        var.database_subnet_names[count.index],
        format("${var.name}-${var.database_subnet_suffix}-%s", element(var.azs, count.index))
      )
    },
    var.tags,
    var.database_subnet_tags,
  )
}

resource "aws_db_subnet_group" "database" {
  count = local.create_database_subnet_group ? 1 : 0

  name        = lower(coalesce(var.database_subnet_group_name, var.name))
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(
    {
      "Name" = lower(coalesce(var.database_subnet_group_name, var.name))
    },
    var.tags,
    var.database_subnet_group_tags,
  )
}

################################################################################
# NAT Gateway
################################################################################

locals {
  nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : try(aws_eip.nat[*].id, [])
}

resource "aws_eip" "nat" {
  count = local.create_vpc && var.enable_nat_gateway && !var.reuse_nat_ips ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
    {
      "Name" = format("${var.name}-%s", element(var.azs, var.single_nat_gateway ? 0 : count.index))
    },
    var.tags,
    var.nat_eip_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format("${var.name}-%s", element(var.azs, var.single_nat_gateway ? 0 : count.index))
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Public Route Tables
################################################################################

resource "aws_route_table" "public" {
  count = local.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = "${var.name}-${var.public_subnet_suffix}"
    },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = local.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = local.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# Private Route Tables
################################################################################

resource "aws_route_table" "private" {
  count = local.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" : format(
        "${var.name}-${var.private_subnet_suffix}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.private_route_table_tags,
  )
}

resource "aws_route" "private_nat_gateway" {
  count = local.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = local.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

################################################################################
# Database Route Tables
################################################################################

resource "aws_route_table" "database" {
  count = local.create_vpc && local.create_database_subnet_route_table && length(var.database_subnets) > 0 ? var.create_database_internet_gateway_route && var.create_igw ? var.single_nat_gateway || var.create_database_nat_gateway_route ? 1 : length(var.database_subnets) : 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = length(var.database_subnets) > 1 && !var.single_nat_gateway && !var.create_database_nat_gateway_route && !var.create_database_internet_gateway_route ? format(
        "${var.name}-${var.database_subnet_suffix}-%s",
        element(var.azs, count.index),
      ) : "${var.name}-${var.database_subnet_suffix}"
    },
    var.tags,
    var.database_route_table_tags,
  )
}

resource "aws_route" "database_internet_gateway" {
  count = local.create_vpc && var.create_igw && var.create_database_internet_gateway_route && length(var.database_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_nat_gateway" {
  count = local.create_vpc && var.enable_nat_gateway && var.create_database_nat_gateway_route && length(var.database_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.database_subnets) : 0

  route_table_id         = element(aws_route_table.database[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(
    aws_nat_gateway.this[*].id,
    count.index,
  )

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "database" {
  count = local.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  subnet_id = element(aws_subnet.database[*].id, count.index)
  route_table_id = element(
    coalescelist(aws_route_table.database[*].id, aws_route_table.private[*].id),
    var.create_database_subnet_route_table ? var.single_nat_gateway || var.create_database_nat_gateway_route ? 0 : count.index : count.index,
  )
}