# AWS VPC Terraform Module

This Terraform module creates a VPC along with public and private subnets. It is designed to provide a complete VPC infrastructure following AWS best practices and using Terraform 1.13+ features.

## Features

- ✅ **VPC**: Complete VPC setup with configurable CIDR blocks
- ✅ **Multiple Subnet Types**: Public, private, and database subnets across multiple AZs
- ✅ **Internet Gateway**: For public subnet internet access
- ✅ **NAT Gateway**: Configurable NAT gateways for private subnet outbound connectivity
- ✅ **Route Tables**: Automatic route table creation and association
- ✅ **Security Groups**: Default security group management
- ✅ **Network ACLs**: Default network ACL management
- ✅ **VPC Endpoints**: S3 and DynamoDB gateway endpoints
- ✅ **VPC Flow Logs**: CloudWatch flow logs support
- ✅ **IPv6 Support**: Optional IPv6 CIDR blocks and subnets
- ✅ **DHCP Options**: Custom DHCP options configuration
- ✅ **Comprehensive Tagging**: Flexible tagging strategy

## Terraform Version Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13 |
| aws | >= 5.70 |

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "path/to/this/module"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

### Complete Example

```hcl
module "vpc" {
  source = "path/to/this/module"

  name = "complete-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  # NAT Gateway
  enable_nat_gateway = true
  one_nat_gateway_per_az = true

  # VPC Flow Logs
  enable_flow_log                   = true
  flow_log_destination_type         = "cloud-watch-logs"

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Default security group
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Endpoints
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  tags = {
    Terraform   = "true"
    Environment = "production"
    Owner       = "infrastructure-team"
  }
}
```

## Best Practices Implemented

### 1. **Security First**
- Default security group configured to deny all traffic by default
- Network ACLs properly configured
- VPC Flow Logs enabled for monitoring

### 2. **High Availability**
- Multi-AZ subnet deployment
- Configurable NAT Gateway deployment strategies
- Proper route table associations

### 3. **Cost Optimization**
- Single NAT Gateway option for cost savings in dev environments
- Optional VPC endpoints to reduce data transfer costs

### 4. **Scalability**
- Support for secondary CIDR blocks
- Flexible subnet configuration
- IPv6 support for future-proofing

### 5. **Monitoring and Observability**
- VPC Flow Logs integration
- Comprehensive output values for integration with other modules

## Architecture Diagrams

### Basic VPC Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│ │   Public AZ-A   │ │   Public AZ-B   │ │   Public AZ-C   │ │
│ │  10.0.101.0/24  │ │  10.0.102.0/24  │ │  10.0.103.0/24  │ │
│ │                 │ │                 │ │                 │ │
│ │   [NAT-GW]      │ │                 │ │                 │ │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘ │
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│ │  Private AZ-A   │ │  Private AZ-B   │ │  Private AZ-C   │ │
│ │   10.0.1.0/24   │ │   10.0.2.0/24   │ │   10.0.3.0/24   │ │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                     [Internet Gateway]
                            │
                        Internet
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used on all the resources as identifier | `string` | n/a | yes |
| cidr | The IPv4 CIDR block for the VPC | `string` | n/a | yes |
| azs | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| public_subnets | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| private_subnets | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| database_subnets | A list of database subnets inside the VPC | `list(string)` | `[]` | no |
| enable_nat_gateway | Should be true if you want to provision NAT Gateways | `bool` | `false` | no |
| single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway | `bool` | `false` | no |
| one_nat_gateway_per_az | Should be true if you want only one NAT Gateway per availability zone | `bool` | `false` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| enable_flow_log | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| enable_s3_endpoint | Should be true if you want to provision an S3 endpoint | `bool` | `false` | no |
| enable_dynamodb_endpoint | Should be true if you want to provision a DynamoDB endpoint | `bool` | `false` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

For a complete list of input variables, see [variables.tf](./variables.tf).

## Output Values

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| private_subnets | List of IDs of private subnets |
| public_subnets | List of IDs of public subnets |
| database_subnets | List of IDs of database subnets |
| nat_ids | List of IDs of the NAT Gateways |
| nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |
| igw_id | The ID of the Internet Gateway |

For a complete list of output values, see [outputs.tf](./outputs.tf).

## Examples

- [Complete VPC](./examples/complete) - Complete VPC with all features enabled
- [Minimal VPC](./examples/minimal) - Simple VPC setup for basic use cases

## Terraform 1.13+ Features Used

This module leverages several Terraform 1.13+ features:

- **Advanced Validation Rules**: Complex validation logic for CIDR blocks and naming conventions
- **Optional Variables**: Extensive use of optional variables with sensible defaults  
- **Dynamic Blocks**: Dynamic configuration blocks for security groups and NACLs
- **Try Function**: Error-safe resource referencing with `try()`
- **Sensitive Variables**: Proper handling of sensitive data
- **Module Meta-Arguments**: Advanced count and for_each usage
- **Local Values**: Complex local value calculations for resource management

## Network Security Best Practices

### Default Security Group
The module manages the default security group and removes all default rules, requiring explicit configuration:

```hcl
manage_default_security_group  = true
default_security_group_ingress = []
default_security_group_egress  = []
```

### Network ACLs
Default Network ACLs are managed with explicit rules:

```hcl
manage_default_network_acl = true
default_network_acl_ingress = [
  {
    rule_no    = 100
    action     = "allow"
    from_port  = 0
    to_port    = 65535
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }
]
```

### VPC Flow Logs
Enable VPC Flow Logs for security monitoring and troubleshooting:

```hcl
enable_flow_log = true
flow_log_destination_type = "cloud-watch-logs"
flow_log_traffic_type = "ALL"
```

## Cost Optimization Strategies

### NAT Gateway Options
1. **Single NAT Gateway** (`single_nat_gateway = true`): Lowest cost, single point of failure
2. **One per AZ** (`one_nat_gateway_per_az = true`): High availability, higher cost
3. **Per private subnet**: Maximum redundancy, highest cost

### VPC Endpoints
Use VPC endpoints to reduce data transfer costs:

```hcl
enable_s3_endpoint = true
enable_dynamodb_endpoint = true
```

## Migration and Upgrades

### From terraform-aws-modules/vpc/aws
This module is compatible with the popular VPC module. Key differences:
- Enhanced validation rules
- Additional Terraform 1.13+ features
- More comprehensive IPv6 support
- Advanced flow logs configuration

### Version Compatibility
- Terraform >= 1.13
- AWS Provider >= 5.70
- Supports latest AWS VPC features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## License

Apache 2.0 Licensed. See LICENSE for full details.

## Authors

Created and maintained by the Infrastructure Team.

## Support

For questions and support:
- Create an issue in this repository
- Contact the infrastructure team
- Review the examples for common use cases