# Terraform Config for Digital Ocean Kubernetes Cluster
Init terraform
```shell
terraform init
```
Plan terraform
```shell
terraform plan -var-file=./terraform/digital-ocean.tfvars
```

Apply terraform
```shell

terraform apply -var-file=./terraform/digital-ocean.tfvars
```

Get the kubeconfig file from the cluster and set the KUBECONFIG environment variable
```shell
export KUBECONFIG=./cluster-config
```
kubectl get nodes




