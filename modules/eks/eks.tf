# Copyright 2020 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


terraform {
  required_version = ">= 0.12.6"
}

provider "aws" {
  version = ">= 3.0"
  region  = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


data "aws_availability_zones" "available" {
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port = 7000
    to_port   = 8000
    protocol  = "udp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc" {
  #source  = "terraform-aws-modules/vpc/aws"
  source  = "../upstream/eks_cluster.vpc"
  #version = "2.47.0"
  #version = "2.78.0"

  name                 = "test-vpc-lt"
  cidr                 = "10.0.0.0/16"
  #azs                  = data.aws_availability_zones.available.names
  azs                  = var.az
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = false
  enable_nat_gateway   = var.enable_nat_gateway

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

module "eks" {
  #source          = "git::github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v13.2.1"
  source          = "../upstream/eks_cluster.eks"
  cluster_name    = var.cluster_name
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_version = var.eks_cluster_version
  config_output_path = var.config_output_path
  manage_aws_auth = true
  worker_additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]

#  node_groups = {
#    default = {
      #desired_capacity  = var.node_count
#      desired_capacity  = 1
      #max_capacity      = var.node_count
#      max_capacity      = 1
      #min_capacity      = var.node_count
#      min_capacity      = 1
#      key_name          = var.key_name
#      worker_additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]

      #instance_type = var.machine_type
#      instance_type = "t3a.small"
#      k8s_labels = {
#        role = "default"
#      }
#      additional_tags = {
#        ExtraTag = "agones-cluster"
#      }
#      update_config = {
#        max_unavailable_percentage = 50 # or set `max_unavailable`
#      }
#    }
#  }
#      arm_worker = {
#      desired_capacity  = var.arm_node_count
#      max_capacity      = var.arm_node_count
#      min_capacity      = var.arm_node_count
#      ami_type          = "AL2_ARM_64"
#      key_name          = var.key_name
#      worker_additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
#
#      instance_type = var.arm_machine_type
#      k8s_labels = {
#        role = "arm-worker"
#      }
#      additional_tags = {
#        ExtraTag = "agones-cluster"
#      }
#      update_config = {
#        max_unavailable_percentage = 50 # or set `max_unavailable`
#      }
#    }
#    
#  }

  worker_groups_launch_template = [
    {
      name                          = "mgmt"
      instance_type                 = var.mgmt_machine_type
      asg_desired_capacity          = var.mgmt_node_count
      asg_min_size                  = var.mgmt_node_count
      asg_max_size                  = var.mgmt_node_count
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      public_ip                     = true
      key_name                      = var.key_name
      kubelet_extra_args   = "--node-labels=role=mgmt-worker"
      bootstrap_extra_args = "--container-runtime containerd"
    },
    {
      name                          = "x86-node"
      instance_type                 = var.machine_type
      asg_desired_capacity          = var.node_count
      asg_min_size                  = var.node_count
      asg_max_size                  = var.node_count
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      public_ip                     = true
      key_name                      = var.key_name
      kubelet_extra_args   = "--node-labels=agones.dev/agones-system=true,role=x86-worker --register-with-taints=agones.dev/agones-system=true:NoExecute"
      bootstrap_extra_args = "--container-runtime containerd"
    },
    {
      name                          = "arm-node"
      instance_type                 = var.arm_machine_type
      ami_id                        = var.arm_machine_ami
      #worker_ami_name_filter        = var.arm_machine_ami_filter
      asg_desired_capacity          = var.arm_node_count
      asg_min_size                  = var.arm_node_count
      asg_max_size                  = var.arm_node_count
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      public_ip                     = true
      key_name                      = var.key_name
      kubelet_extra_args   = "--node-labels=agones.dev/agones-system=true,role=arm-worker --register-with-taints=agones.dev/agones-system=true:NoExecute"
      bootstrap_extra_args = "--container-runtime containerd"
    }
  ]


}
