#!/bin/bash

start=$(date +%s)
# Description: This script will create a kubernetes cluster on Digital Ocean using Terraform and Ansible
echo "Creating a Kubernetes cluster on Digital Ocean..."
echo "Running Terraform to create the droplets..."
terraform -chdir=./terraform init
terraform -chdir=./terraform apply -var-file=digital-ocean.tfvars -auto-approve
echo "Waiting for the droplets to be created and ready..."
sleep 30 # Wait for the droplets to be created and ready
echo "Droplets are ready. Running Ansible playbook to create the cluster..."
ansible-playbook ./ansible/playbooks/create-cluster/playbook.yml
echo "Kubernetes cluster on Digital Ocean created successfully."
end=$(date +%s)
runtime=$((end-start))
echo "Run time: $runtime sec"
echo "Waiting for the Kubernetes cluster to be ready..."
sleep 30
echo "Kubernetes cluster is ready. Here are the nodes:"
kubectl get nodes
