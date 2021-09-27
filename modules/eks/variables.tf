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

variable "cluster_name" {
  default = "test-cluster"
}

variable "eks_cluster_version" {
  default = "1.20"
}

variable "region" {
  default = "us-west-2"
}

variable "az" {
  default = ""
}

variable "enable_nat_gateway" {
  default = "false"
}

variable "machine_type" {
  default = "t2.large"
}

variable "mgmt_machine_type" {
  default = "t2.large"
}

variable "arm_machine_type" {
  default = "a1.large"
}

variable "arm_machine_ami" {
  default = ""
}

variable "node_count" {
  default = "1"
}

variable "mgmt_node_count" {
  default = "2"
}

variable "arm_node_count" {
  default = "1"
}

variable "arm_machine_ami_filter" {
  default = ""
}

variable "key_name" {
  default = ""
}

variable "config_output_path" {
  default = ""
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "777777777777",
    "888888888888",
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type        = list(map(string))

  default = [
    {
      role_arn = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      group    = "system:masters"
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        = list(map(string))

  default = [
    {
      user_arn = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      group    = "system:masters"
    },
    {
      user_arn = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      group    = "system:masters"
    },
  ]
}
