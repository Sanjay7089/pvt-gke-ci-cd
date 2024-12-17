all-resource:
	cd Terraform/env/dev \
	terraform init && terraform fmt && terraform validate && terraform plan -var-file=variables.tfvars && terraform apply -var-file=variables.tfvars --auto-approve \

