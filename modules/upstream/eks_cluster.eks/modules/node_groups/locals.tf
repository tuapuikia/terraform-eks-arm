locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      desired_capacity        = var.workers_group_defaults["asg_desired_capacity"]
      iam_role_arn            = var.default_iam_role_arn
      instance_type           = var.workers_group_defaults["instance_type"]
      key_name                = var.workers_group_defaults["key_name"]
      launch_template_id      = var.workers_group_defaults["launch_template_id"]
      launch_template_version = var.workers_group_defaults["launch_template_version"]
      max_capacity            = var.workers_group_defaults["asg_max_size"]
      min_capacity            = var.workers_group_defaults["asg_min_size"]
      subnets                 = var.workers_group_defaults["subnets"]
      metadata_http_endpoint               = var.workers_group_defaults["metadata_http_endpoint"]
      metadata_http_tokens                 = var.workers_group_defaults["metadata_http_tokens"]
      metadata_http_put_response_hop_limit = var.workers_group_defaults["metadata_http_put_response_hop_limit"]
    },
    var.node_groups_defaults,
    v,
  ) if var.create_eks }
  node_groups_names = { for k, v in local.node_groups_expanded : k => lookup(
    v,
    "name",
    lookup(
      v,
      "name_prefix",
      join("-", [var.cluster_name, k])
    )
  ) }
}
