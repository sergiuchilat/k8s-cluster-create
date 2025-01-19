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

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/manifests/namespace.yaml

# Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
kubectl apply -f ./deployments/test-app/a.yaml

kubectl get pods -n ingress-nginx
kubectl logs ingress-nginx-controller-974f4cbd8-b62vs -n ingress-nginx



