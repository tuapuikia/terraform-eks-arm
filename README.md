# This is a forked module and TF template from Agones.dev

How to create an EKS cluster with ARM instance group and Agones installed.

0. Download Terraform version 0.12.x
1. git clone https://github.com/tuapuikia/terraform-eks-arm
2. cd eks
3. change the module.tf according to the AWS region you want to use.
4. terraform init
5. terraform plan (review the change)
6. terraform apply

**Kubeconfig will be installed to /root/.kube/config** 

Supertuxkart game server for x86 and arm64 is in agones directory.

0. kubectl apply -f agones/
1. kubectl get gameserver
