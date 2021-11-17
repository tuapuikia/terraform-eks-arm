// Copyright 2020 Google LLC All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


// Run:
//  terraform apply [-var agones_version="1.4.0"]

// Install latest version of agones

data "aws_ami" "arm_worker_ami" {
  filter {
    name = "name"
    values = ["amazon-eks-arm64-node-${var.eks_cluster_version}-v*"]
  }
  most_recent = true
  owners = ["602401143452"]
}

variable "agones_version" {
  default = "1.17.0"
}

variable "agones_image_registry" {
  default = "tuapuikia"
}

variable "agones_image_sdk_tag" {
  default = "1.18"
}

variable "cluster_name" {
  default = "agones-cluster"
}

variable "eks_cluster_version" {
  default = "1.20"
}

variable "region" {
  default = "ap-southeast-1"
}

variable "az" {
  default = ["ap-southeast-1a","ap-southeast-1b"]
}

variable "node_count" {
  default = "1"
}

variable "arm_node_count" {
  default = "1"
}

variable "arm_machine_ami" {
  default = ""
}

variable "key_name" {
  default = "eks"
}

provider "aws" {
  version = "~> 3.0"
  region  = var.region
}

variable "machine_type" { default = "c5.large" }

variable "arm_machine_type" { default = "c6g.large" }

variable "log_level" {
  default = "debug"
}

variable "feature_gates" {
  default = "PlayerTracking=true"
}

variable "agones_controller_nodeSelector" {
  default = "x86-worker"
}

variable "agones_ping_nodeSelector" {
  default = "x86-worker"
}

variable "agones_allocator_nodeSelector" {
  default = "x86-worker"
}

variable "agones_allocator_http_serviceType" {
  default = "LoadBalancer"
}

module "eks_cluster" {
  source = "../modules/eks"

  machine_type      = var.machine_type
  arm_machine_type  = var.arm_machine_type
  arm_machine_ami   = data.aws_ami.arm_worker_ami.id
  cluster_name      = var.cluster_name
  node_count        = var.node_count
  arm_node_count    = var.arm_node_count
  region            = var.region
  az                = var.az
  key_name          = var.key_name
  config_output_path = "/root/.kube/config"
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}

// Next Helm module cause "terraform destroy" timeout, unless helm release would be deleted first.
// Therefore "helm delete --purge agones" should be executed from the CLI before executing "terraform destroy".
module "helm_agones" {
  source = "../modules/helm3"

  udp_expose             = "false"
  agones_version         = var.agones_version
  values_file            = ""
  feature_gates          = var.feature_gates
  host                   = module.eks_cluster.host
  token                  = data.aws_eks_cluster_auth.example.token
  cluster_ca_certificate = module.eks_cluster.cluster_ca_certificate
  log_level              = var.log_level
  image_registry         = var.agones_image_registry
  image_sdk_tag          = var.agones_image_sdk_tag
  agones_controller_nodeSelector  = var.agones_controller_nodeSelector
  agones_ping_nodeSelector        = var.agones_ping_nodeSelector
  agones_allocator_nodeSelector   = var.agones_allocator_nodeSelector
  agones_allocator_http_serviceType = var.agones_allocator_http_serviceType

}

output "host" {
  value = "${module.eks_cluster.host}"
}
output "cluster_ca_certificate" {
  value = "${module.eks_cluster.cluster_ca_certificate}"
}
