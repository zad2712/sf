.PHONY: help init validate plan apply destroy clean format docs test

# Default target
help: ## Show this help message
	@echo "AWS VPC Terraform Module"
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Terraform operations
init: ## Initialize Terraform
	terraform init

validate: init ## Validate Terraform configuration
	terraform validate

format: ## Format Terraform files
	terraform fmt -recursive

plan: validate ## Create Terraform execution plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy Terraform-managed infrastructure
	terraform destroy

# Documentation
docs: ## Generate documentation
	terraform-docs markdown table --output-file README.md .

# Testing
test-examples: ## Test all examples
	@echo "Testing minimal example..."
	cd examples/minimal && terraform init && terraform validate && terraform plan
	@echo "Testing complete example..."
	cd examples/complete && terraform init && terraform validate && terraform plan

# Linting and security
lint: ## Run tflint
	tflint

security: ## Run security checks
	tfsec .
	checkov -d .

# Cleanup
clean: ## Clean up temporary files
	find . -type f -name "*.tfplan" -delete
	find . -type f -name "*.tfstate*" -delete
	find . -type d -name ".terraform" -exec rm -rf {} +

# Development workflow
check: format validate lint security ## Run all checks

# Version management
version: ## Show version information
	@echo "Terraform: $(shell terraform version -json | jq -r '.terraform_version')"
	@echo "AWS Provider: $(shell terraform providers | grep 'hashicorp/aws' || echo 'Not initialized')"

# Complete workflow
all: clean init validate format lint test-examples docs ## Run complete development workflow