# Terraform Notes

## Layout
- `modules/`: reusable infra units (vpc, ecs-service, rds)
- `envs/`: per-environment stacks (dev, staging, prod)

## Commands
```bash
# format and validate
terraform fmt -recursive
terraform init && terraform validate

# plan with workspace
terraform workspace select staging || terraform workspace new staging
terraform plan -var-file=envs/staging.tfvars

# apply (use approvals!)
terraform apply -var-file=envs/staging.tfvars
```

## State
- Backend: S3 + DynamoDB lock
- Bucket policy: restrict to org principals only
- Versioning: enabled; lifecycle transitions to IA after 30d

## Patterns
- Use `for_each` for per-tenant resources
- Expose outputs with minimal surface area; avoid leaking secrets
- Keep providers pinned to exact version

## Checklist before apply
- [ ] `terraform fmt` clean
- [ ] Drift checked
- [ ] Plans shared in PR
- [ ] Break-glass IAM ready if lock table fails

## References
- [Release checklist](../ops/release-checklist.md)
- [Architecture overview](../architecture/overview.md)
