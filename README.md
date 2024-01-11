# ECS with Terraform PoC

This repo hosts an sample configuration to prepare an ECS cluster using Terraform.

Explore the following files in this order:
- `backend.tf`
- `provider.tf`
- `variables.tf`
- `network.tf`
- `security.tf`
- `alb.tf`
- `ecs.tf`
- `auto_scaling.tf`
- `logs.tf`
- `outputs.tf`

### Run

1. make sure aws configs are saved and the correct profile is given in `provider.tf`
1. change the variables according to your needs in `vars.tfvars`
1. run 
```shell
terraform init --reconfigure
terraform plan -var-file=vars.tfvars -out tfplan
terraform apply "tfplan"
```

once done, it'll print the URL that you can use to access the application.


### Next steps

- Link a valid domain to the given load balancer
