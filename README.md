# Terragrunt Live Infrastructure Demo

This repository contains live Terragrunt configurations that use modules from the [tg-modules-demo](https://github.com/etamarw/tg-modules-demo) repository. It demonstrates how to structure a live infrastructure repository with Renovate automation for module updates.

## Repository Structure

```
tg-live-demo/
├── terragrunt.hcl              # Root configuration with common settings
├── live/                       # Live infrastructure configurations
│   ├── dev/                   # Development environment
│   │   └── us-west-2/         # AWS region
│   │       ├── vpc/           # VPC infrastructure
│   │       └── security-groups/ # Security groups (depends on VPC)
│   └── staging/               # Staging environment
│       └── us-west-2/         # AWS region
│           ├── vpc/           # VPC infrastructure
│           └── security-groups/ # Security groups (depends on VPC)
├── renovate.json              # Renovate configuration for module updates
├── .gitignore                 # Git ignore patterns
└── README.md                  # This file
```

## Features

### 🏗️ **Multi-Environment Support**
- **Dev Environment**: Full access for development and testing
- **Staging Environment**: Production-like environment for final testing
- Easy to extend with additional environments (prod, qa, etc.)

### 🔄 **Automated Module Updates**
- **Renovate Integration**: Automatically monitors the modules repository for new releases
- **Pull Request Automation**: Creates PRs when module versions are updated
- **Dependency Grouping**: Groups related module updates together
- **Review Process**: Requires manual review before merging updates

### 🌍 **Multi-Region Ready**
- Current setup: `us-west-2`
- Easy to extend to multiple AWS regions
- Regional resource isolation

### 🔒 **Dependency Management**
- **VPC First**: VPC must be deployed before security groups
- **Explicit Dependencies**: Using Terragrunt's `dependency` blocks
- **Mock Outputs**: Allows planning without deployed dependencies

## Getting Started

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0
3. **Terragrunt** >= 0.45.0
4. **S3 Bucket** for remote state storage
5. **DynamoDB Table** for state locking

### Initial Setup

1. **Update Remote State Configuration**
   
   Edit `terragrunt.hcl` and update the S3 bucket names and DynamoDB table names to match your AWS setup:
   ```hcl
   bucket         = "your-terraform-state-${local.aws_region}"
   dynamodb_table = "terraform-locks-${local.aws_region}"
   ```

2. **Deploy Infrastructure**
   
   Deploy in dependency order:
   ```bash
   # Deploy VPC first
   cd live/dev/us-west-2/vpc
   terragrunt apply
   
   # Then deploy security groups
   cd ../security-groups
   terragrunt apply
   ```

3. **Deploy Staging**
   ```bash
   # Deploy staging VPC
   cd live/staging/us-west-2/vpc
   terragrunt apply
   
   # Deploy staging security groups
   cd ../security-groups
   terragrunt apply
   ```

## Module References

All modules are sourced from the [tg-modules-demo](https://github.com/etamarw/tg-modules-demo) repository with pinned versions:

- **VPC Module**: `git::https://github.com/etamarw/tg-modules-demo.git//modules/vpc?ref=v1.0.0`
- **Security Groups Module**: `git::https://github.com/etamarw/tg-modules-demo.git//modules/security-groups?ref=v1.0.0`

## Renovate Automation

### How It Works

1. **Monitoring**: Renovate monitors the `etamarw/tg-modules-demo` repository for new releases
2. **Detection**: When a new version tag is created (e.g., `v1.1.0`), Renovate detects it
3. **PR Creation**: Renovate creates a pull request updating all module references to the new version
4. **Review**: The PR requires manual review before merging
5. **Deployment**: After merging, run `terragrunt apply` in affected directories

### Renovate Configuration

- **Schedule**: Runs weekly on Mondays before 9 AM
- **Grouping**: All module updates are grouped into a single PR
- **Labels**: PRs are labeled with `dependencies`, `modules`, `renovate`
- **Assignee**: PRs are assigned to `etamarw` for review

### Manual Trigger

You can manually trigger Renovate through the GitHub App dashboard or by creating an issue with the title "Renovate: Update dependencies".

## Development Workflow

### Adding New Environments

1. Create new directory: `live/{environment}/{region}/`
2. Copy service configurations from existing environment
3. Update environment-specific values (CIDR blocks, naming, etc.)
4. Deploy in dependency order

### Adding New Services

1. Create service directory: `live/{environment}/{region}/{service}/`
2. Create `terragrunt.hcl` with module reference
3. Add any required dependencies using `dependency` blocks
4. Update this README with the new service

### Testing Changes

1. **Plan First**: Always run `terragrunt plan` before applying
2. **Dependency Order**: Deploy dependencies before dependents
3. **Rollback Plan**: Have a rollback strategy for production changes

## Best Practices

### 🔒 **Security**
- Use separate AWS accounts for different environments
- Implement least-privilege IAM policies
- Regular security audits of infrastructure

### 📦 **Module Versioning**
- Always pin module versions in live configurations
- Test module updates in dev environment first
- Use semantic versioning for module releases

### 🚀 **Deployment**
- Deploy changes during maintenance windows
- Use blue-green deployments for zero-downtime updates
- Monitor infrastructure after changes

### 🔄 **State Management**
- Use separate state files for each service
- Regular state backups
- State locking to prevent conflicts

## Troubleshooting

### Common Issues

1. **State Lock**: If state is locked, check DynamoDB table and remove stale locks
2. **Dependency Errors**: Ensure dependencies are deployed before dependents
3. **Module Not Found**: Verify module repository access and version tags

### Getting Help

- Check Terragrunt logs: `terragrunt apply --terragrunt-log-level debug`
- Validate configuration: `terragrunt validate`
- Plan changes: `terragrunt plan`

## Contributing

1. Create feature branches for changes
2. Test in dev environment first
3. Update documentation for new features
4. Follow semantic versioning for releases
