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

#
# This is a Helm 3.x module, and is the module that should be actively used.
#

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  force_update     = var.prom_force_update
  chart            = var.prom_chart
  timeout          = 420
  namespace        = "monitoring"
  create_namespace = true

  # Use terraform of the latest >=0.12 version
  values = [
    length(var.values_file) == 0 ? "" : file(var.values_file),
  ]

  set {
    name  = "server.service.type"
    value = var.prom_server_service_type
  }

  set {
    name = "server.global.scrape_interval"
    value = var.prom_server_global_scrape_interval
  }

}
