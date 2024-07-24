resource "outscale_access_key" "this" {
  count           = length(var.access_key)
  expiration_date = lookup(var.access_key[count.index], "expiration_date")
  state           = lookup(var.access_key[count.index], "state")
}

resource "outscale_api_access_policy" "this" {
  count                             = length(var.api_access_policy)
  max_access_key_expiration_seconds = lookup(var.api_access_policy[count.index], "max_access_key_expiration_seconds")
  require_trusted_env               = lookup(var.api_access_policy[count.index], "require_trusted_env")
}

resource "outscale_api_access_rule" "this" {
  count       = length(var.api_access_rule)
  ca_ids      = lookup(var.api_access_rule[count.index], "ca_ids")
  cns         = lookup(var.api_access_rule[count.index], "cns")
  description = lookup(var.api_access_rule[count.index], "description")
  ip_ranges   = lookup(var.api_access_rule[count.index], "ip_ranges")
}

resource "outscale_ca" "this" {
  count       = length(var.ca)
  ca_pem      = file(join("/", [path.cwd, "certificate", lookup(var.ca[count.index], "ca_pem")]))
  description = lookup(var.ca[count.index], "description")
}

resource "outscale_client_gateway" "this" {
  count           = length(var.public_ip) == 0 ? 0 : length(var.client_gateway)
  bgp_asn         = lookup(var.client_gateway[count.index], "bgp_asn")
  connection_type = lookup(var.client_gateway[count.index], "connection_type")
  public_ip = try(
    element(outscale_public_ip.this.*.public_ip, lookup(var.client_gateway[count.index], "public_ip_id"))
  )

  dynamic "tags" {
    for_each = lookup(var.client_gateway[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_dhcp_option" "this" {
  count               = length(var.dhcp_option)
  domain_name         = lookup(var.dhcp_option[count.index], "domain_name")
  domain_name_servers = lookup(var.dhcp_option[count.index], "domain_name_servers")
  log_servers         = lookup(var.dhcp_option[count.index], "log_servers")
  ntp_servers         = lookup(var.dhcp_option[count.index], "ntp_servers")

  dynamic "tags" {
    for_each = lookup(var.dhcp_option[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_flexible_gpu" "this" {
  count                 = length(var.flexible_gpu)
  model_name            = lookup(var.flexible_gpu[count.index], "model_name")
  subregion_name        = lookup(var.flexible_gpu[count.index], "subregion_name")
  delete_on_vm_deletion = lookup(var.flexible_gpu[count.index], "delete_on_vm_deletion")
  generation            = lookup(var.flexible_gpu[count.index], "generation")
}

resource "outscale_flexible_gpu_link" "this" {
  count = (length(var.vm) && length(var.flexible_gpu)) == 0 ? 0 : length(var.flexible_gpu_link)
  flexible_gpu_id = try(
    element(outscale_flexible_gpu.this.*.id, lookup(var.flexible_gpu_link[count.index], "flexible_gpu_id"))
  )
  vm_id = try(
    element(outscale_vm.this.*.id, lookup(var.flexible_gpu_link[count.index], "vm_id"))
  )
}

resource "outscale_image" "this" {
  count              = length(var.image)
  architecture       = lookup(var.image[count.index], "architecture")
  description        = lookup(var.image[count.index], "description")
  file_location      = lookup(var.image[count.index], "file_location")
  image_name         = lookup(var.image[count.index], "image_name")
  no_reboot          = lookup(var.image[count.index], "no_reboot")
  root_device_name   = lookup(var.image[count.index], "root_device_name")
  source_image_id    = lookup(var.image[count.index], "source_image_id")
  source_region_name = lookup(var.image[count.index], "source_region_name")
  vm_id = try(
    element(outscale_vm.this.*.vm_id, lookup(var.image[count.index], "vm_id"))
  )

  dynamic "block_device_mappings" {
    for_each = lookup(var.image[count.index], "block_device_mappings") == null ? [] : ["block_device_mappings"]
    content {
      device_name         = lookup(block_device_mappings.value, "device_name")
      virtual_device_name = lookup(block_device_mappings.value, "virtual_device_name")

      dynamic "bsu" {
        for_each = lookup(block_device_mappings.value, "bsu") == null ? [] : ["bsu"]
        content {
          delete_on_vm_deletion = lookup(bsu.value, "delete_on_vm_deletion")
          iops                  = lookup(bsu.value, "iops")
          snapshot_id = try(
            element(outscale_snapshot.this.*.snapshot_id, lookup(bsu.value, "snapshot_id"))
          )
          volume_size = lookup(bsu.value, "volume_size")
          volume_type = lookup(bsu.value, "volume_type")
        }
      }
    }
  }

  dynamic "tags" {
    for_each = lookup(var.image[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_image_export_task" "this" {
  count = (length(var.image) || var.data_image != null) == 0 ? 0 : length(var.image_export_task)
  image_id = try(
    element(
      outscale_image.this.*.id, lookup(var.image_export_task[count.index], "image_id")
    )
  )

  dynamic "osu_export" {
    for_each = lookup(var.image_export_task[count.index], "osu_export") == null ? [] : ["osu_export"]
    content {
      disk_image_format = lookup(osu_export[count.index], "disk_image_format")
      osu_bucket        = lookup(osu_export[count.index], "osu_bucket")
      osu_manifest_url  = lookup(osu_export[count.index], "osu_manifest_url")
      osu_prefix        = lookup(osu_export[count.index], "osu_prefix")

      dynamic "osu_api_key" {
        for_each = lookup(osu_export.value, "osu_api_key") == null ? [] : ["osu_api_key"]
        content {
          api_key_id = lookup(osu_api_key.value, "api_key_id")
          secret_key = lookup(osu_api_key.value, "secret_key")
        }
      }
    }
  }

  dynamic "tags" {
    for_each = lookup(var.image_export_task[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_image_launch_permission" "this" {
  count = (length(var.image) || var.data_image != null) == 0 ? 0 : length(var.image_launch_permission)
  image_id = try(
    element(
      outscale_image.this.*.id, lookup(var.image_launch_permission[count.index], "image_id")
    )
  )

  dynamic "permission_additions" {
    for_each = lookup(var.image_launch_permission[count.index], "permission_additions") == null ? [] : ["permission_additions"]
    content {
      account_ids       = lookup(permission_additions.value, "account_ids")
      global_permission = lookup(permission_additions.value, "global_permission")
    }
  }

  dynamic "permission_removals" {
    for_each = lookup(var.image_launch_permission[count.index], "permission_removals") == null ? [] : ["permission_removals"]
    content {
      account_ids       = lookup(permission_removals.value, "account_ids")
      global_permission = lookup(permission_removals.value, "global_permission")
    }
  }
}

resource "outscale_internet_service" "this" {
  count = length(var.internet_service)

  dynamic "tags" {
    for_each = lookup(var.internet_service[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_internet_service_link" "this" {
  count = (length(var.net) && length(var.internet_service)) == 0 ? 0 : length(var.internet_service_link)
  internet_service_id = try(
    element(outscale_internet_service.this.*.id, lookup(var.internet_service_link[count.index], "internet_service_id"))
  )
  net_id = try(
    element(outscale_net.this.*.id, lookup(var.internet_service_link[count.index], "net_id"))
  )
}

resource "outscale_keypair" "this" {
  count        = length(var.keypair)
  keypair_name = lookup(var.keypair[count.index], "keypair_name")
  public_key   = file(join("/", [path.cwd, "keys", lookup(var.keypair[count.index], "public_key")]))
}

resource "outscale_load_balancer" "this" {
  count              = length(var.load_balancer)
  load_balancer_name = lookup(var.load_balancer[count.index], "load_balancer_name")
  load_balancer_type = lookup(var.load_balancer[count.index], "load_balancer_type")
  public_ip = try(
    element(outscale_public_ip.this.*.public_ip, lookup(var.load_balancer[count.index], "public_ip_id"))
  )
  security_groups = [
    try(
      element(outscale_security_group.this.*.security_group_id, lookup(var.load_balancer[count.index], "security_groups_id"))
    )
  ]
  subnets = [
    try(
      element(outscale_subnet.this.*.subnet_id, lookup(var.load_balancer[count.index], "subnet_id"))
    )
  ]
  subregion_names = lookup(var.load_balancer[count.index], "subregion_names")

  dynamic "listeners" {
    for_each = lookup(var.load_balancer[count.index], "listeners") == null ? [] : ["listeners"]
    content {
      backend_port           = lookup(listeners.value, "backend_port")
      backend_protocol       = lookup(listeners.value, "backend_protocol")
      load_balancer_port     = lookup(listeners.value, "load_balancer_port")
      load_balancer_protocol = lookup(listeners.value, "load_balancer_protocol")
      server_certificate_id  = lookup(listeners.value, "server_certificate_id")
    }
  }

  dynamic "tags" {
    for_each = lookup(var.load_balancer[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_load_balancer_attributes" "this" {
  count = length(var.load_balancer) == 0 ? 0 : length(var.load_balancer_attributes)
  load_balancer_name = try(
    element(outscale_load_balancer.this.*.id, lookup(var.load_balancer_attributes[count.index], "load_balancer_id"))
  )
  load_balancer_port = lookup(var.load_balancer_attributes[count.index], "load_balancer_port")
  policy_names = [
    try(
      element(outscale_load_balancer_policy.this.*.policy_name, lookup(var.load_balancer_attributes[count.index], "policy_id"))
    )
  ]
  server_certificate_id = lookup(var.load_balancer_attributes[count.index], "server_certificate_id")

  dynamic "access_log" {
    for_each = lookup(var.load_balancer_attributes[count.index], "access_log") == null ? [] : ["access_log"]
    content {
      is_enabled           = lookup(access_log.value, "is_enabled")
      osu_bucket_name      = lookup(access_log.value, "osu_bucket_name")
      osu_bucket_prefix    = lookup(access_log.value, "osu_bucket_prefix")
      publication_interval = lookup(access_log.value, "publication_interval")
    }
  }

  dynamic "health_check" {
    for_each = lookup(var.load_balancer_attributes[count.index], "health_check") == null ? [] : ["health_check"]
    content {
      check_interval      = lookup(health_check.value, "check_interval")
      healthy_threshold   = lookup(health_check.value, "healthy_threshold")
      port                = lookup(health_check.value, "port")
      protocol            = lookup(health_check.value, "protocol")
      timeout             = lookup(health_check.value, "timeout")
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold")
    }
  }

  dynamic "tags" {
    for_each = lookup(var.load_balancer[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_load_balancer_listener_rule" "this" {
  count = length(var.vm) == 0 ? 0 : length(var.load_balancer_listener_rule)
  vm_ids = [
    try(
      element(outscale_vm.this.*.id, lookup(var.load_balancer_listener_rule[count.index], "vm_ids"))
    )
  ]

  dynamic "listener" {
    for_each = lookup(var.load_balancer_listener_rule[count.index], "listener") == null ? [] : ["listener"]
    content {
      load_balancer_name = try(
        element(outscale_load_balancer.this.*.load_balancer_name, lookup(listener.value, "load_balancer_id"))
      )
      load_balancer_port = lookup(listener.value, "load_balancer_port")
    }
  }

  dynamic "listener_rule" {
    for_each = lookup(var.load_balancer_listener_rule[count.index], "listener_rule") == null ? [] : ["listener_rule"]
    content {
      listener_rule_name = lookup(listener_rule[count.index], "listener_rule_name")
      priority           = lookup(listener_rule[count.index], "priority")
      action             = lookup(listener_rule[count.index], "action")
      host_name_pattern  = lookup(listener_rule[count.index], "host_name_pattern")
      path_pattern       = lookup(listener_rule[count.index], "path_pattern")
    }
  }
}

resource "outscale_load_balancer_policy" "this" {
  count = length(var.load_balancer) == 0 ? 0 : length(var.load_balancer_policy)
  load_balancer_name = try(
    element(outscale_load_balancer.this.*.load_balancer_name, lookup(var.load_balancer_policy[count.index], "load_balancer_id"))
  )
  policy_name = lookup(var.load_balancer_policy[count.index], "policy_name")
  policy_type = lookup(var.load_balancer_policy[count.index], "policy_type")
  cookie_name = lookup(var.load_balancer_policy[count.index], "cookie_name")
}

resource "outscale_load_balancer_vms" "this" {
  count = (length(var.vm) && length(var.load_balancer)) == 0 ? 0 : length(var.load_balancer_vms)
  backend_vm_ids = [try(
    element(outscale_vm.this.*.id, lookup(var.load_balancer_vms[count.index], "backend_vm_ids"))
  )]
  load_balancer_name = try(
    element(outscale_load_balancer.this.*.load_balancer_name, lookup(var.load_balancer_vms[count.index], "load_balancer_id"))
  )
}

resource "outscale_nat_service" "this" {
  count = (length(outscale_public_ip) && length(var.subnet)) == 0 ? 0 : length(var.nat_service)
  public_ip_id = try(
    element(outscale_public_ip.this.*.id, lookup(var.nat_service[count.index], "public_ip_id"))
  )
  subnet_id = try(
    element(outscale_subnet.this.*.subnet_id, lookup(var.nat_service[count.index], "subnet_id"))
  )

  dynamic "tags" {
    for_each = lookup(var.nat_service[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_net" "this" {
  count    = length(var.net)
  ip_range = lookup(var.net[count.index], "ip_range")
  tenancy  = lookup(var.net[count.index], "tenancy")

  dynamic "tags" {
    for_each = lookup(var.net[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_net_access_point" "this" {
  count = length(var.net) == 0 ? 0 : length(var.net_access_point)
  net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.net_access_point[count.index], "net_id"))
  )
  service_name = lookup(var.net_access_point[count.index], "service_name")
  route_table_ids = [
    try(
      element(outscale_route_table.this.*.route_table_id, lookup(var.net_access_point[count.index], "route_table_ids"))
    )
  ]

  dynamic "tags" {
    for_each = lookup(var.net[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_net_attributes" "this" {
  count = (length(var.net) && length(var.dhcp_option)) == 0 ? 0 : length(var.net_attributes)
  net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.net_attributes[count.index], "net_id"))
  )
  dhcp_options_set_id = try(
    element(outscale_dhcp_option.this.*.dhcp_options_set_id, lookup(var.net_attributes[count.index], "dhcp_options_set_id"))
  )
}

resource "outscale_net_peering" "this" {
  count = length(var.net) == 0 ? 0 : length(var.net_peering)
  accepter_net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.net_peering[count.index], "accepter_net_id"))
  )
  source_net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.net_peering[count.index], "source_net_id"))
  )

  dynamic "tags" {
    for_each = lookup(var.net[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_net_peering_acceptation" "this" {
  count = length(var.net_peering) == 0 ? 0 : length(var.net_peering_acceptation)
  net_peering_id = try(
    element(outscale_net_peering.this.*.net_peering_id, lookup(var.net_peering_acceptation[count.index], "net_peering_id"))
  )
}

resource "outscale_nic" "this" {
  count = length(var.subnet) == 0 ? 0 : length(var.nic)
  subnet_id = try(
    element(outscale_subnet.this.*.subnet_id, lookup(var.nic[count.index], "subnet_id"))
  )
  description = lookup(var.nic[count.index], "description")
  private_ip  = lookup(var.nic[count.index], "private_ip")
  security_group_ids = [
    try(
      element(outscale_security_group.this.*.security_group_id, lookup(var.nic[count.index], "security_group_ids"))
    )
  ]

  dynamic "private_ips" {
    for_each = lookup(var.nic[count.index], "private_ips") == null ? [] : ["private_ips"]
    content {
      is_primary = lookup(private_ips.value, "is_primary")
      private_ip = lookup(private_ips.value, "private_ip")
    }
  }

  dynamic "tags" {
    for_each = lookup(var.nic[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_nic_link" "this" {
  count         = (length(var.nic) && length(var.vm)) == 0 ? 0 : length(var.nic_link)
  device_number = lookup(var.nic_link[count.index], "device_number")
  nic_id = try(
    element(outscale_nic.this.*.nic_id, lookup(var.nic_link[count.index], "nic_id"))
  )
  vm_id = try(
    element(outscale_vm.this.*.vm_id, lookup(var.nic_link[count.index], "vm_id"))
  )
}

resource "outscale_nic_private_ip" "this" {
  count = length(var.nic) == 0 ? 0 : length(var.nic_private_ip)
  nic_id = try(
    element(outscale_nic.this.*.nic_id, lookup(var.nic_private_ip[count.index], "nic_id"))
  )
  allow_relink               = lookup(var.nic_private_ip[count.index], "allow_relink")
  private_ips                = lookup(var.nic_private_ip[count.index], "private_ips")
  secondary_private_ip_count = lookup(var.nic_private_ip[count.index], "secondary_private_ip_count")
}

resource "outscale_public_ip" "this" {
  count = length(var.public_ip)

  dynamic "tags" {
    for_each = lookup(var.public_ip[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_public_ip_link" "this" {
  count        = length(var.public_ip_link)
  allow_relink = true
  nic_id = try(
    element(outscale_nic.this.*.nic_id, lookup(var.public_ip_link[count.index], "nic_id"))
  )
  private_ip = try(
    element(outscale_nic_private_ip.this.*.primary_private_ip, lookup(var.public_ip_link[count.index], "private_ip"))
  )
  public_ip = try(
    element(outscale_public_ip.this.*.public_ip, lookup(var.public_ip_link[count.index], "public_ip_id"))
  )
  public_ip_id = try(
    element(outscale_public_ip.this.*.public_ip_id, lookup(var.public_ip_link[count.index], "public_ip_id"))
  )
  vm_id = try(
    element(outscale_vm.this.*.vm_id, lookup(var.public_ip_link[count.index], "vm_id"))
  )
}

resource "outscale_route" "this" {
  count                = length(var.route_table) == 0 ? 0 : length(var.route)
  destination_ip_range = lookup(var.route[count.index], "destination_ip_range")
  route_table_id = try(
    element(outscale_route_table.this.*.route_table_id, lookup(var.route[count.index], "route_table_id"))
  )
  await_active_state = lookup(var.route[count.index], "await_active_state")
  nat_service_id = try(
    element(outscale_nat_service.this.*.nat_service_id, lookup(var.route[count.index], "nat_service_id"))
  )
  net_peering_id = try(
    element(outscale_net_peering.this.*.net_peering_id, lookup(var.route[count.index], "net_peering_id"))
  )
  nic_id = try(
    element(outscale_nic.this.*.nic_id, lookup(var.route[count.index], "nic_id"))
  )
  vm_id = try(
    element(outscale_vm.this.*.vm_id, lookup(var.route[count.index], "vm_id"))
  )
}

resource "outscale_route_table" "this" {
  count = length(var.net) == 0 ? 0 : length(var.route_table)
  net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.route_table[count.index], "net_id"))
  )

  dynamic "tags" {
    for_each = lookup(var.route_table[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_route_table_link" "this" {
  count = (length(var.route_table) && length(var.subnet)) == 0 ? 0 : length(var.route_table_link)
  route_table_id = try(
    element(outscale_route_table.this.*.route_table_id, lookup(var.route_table_link[count.index], "route_table_id"))
  )
  subnet_id = try(
    element(outscale_subnet.this.*.subnet_id, lookup(var.route_table_link[count.index], "subnet_id"))
  )
}

resource "outscale_security_group" "this" {
  count       = length(var.security_group)
  description = lookup(var.security_group[count.index], "description")
  net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.security_group[count.index], "net_id"))
  )
  remove_default_outbound_rule = lookup(var.security_group[count.index], "remove_default_outbound_rule")
  security_group_name          = lookup(var.security_group[count.index], "security_group_name")

  dynamic "tags" {
    for_each = lookup(var.security_group[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_security_group_rule" "this" {
  count = length(var.security_group) == 0 ? 0 : length(var.security_group_rule)
  flow  = lookup(var.security_group_rule[count.index], "flow")
  security_group_id = try(
    element(outscale_security_group.this.*.security_group_id, lookup(var.security_group_rule[count.index], "security_group_id"))
  )
  from_port_range = lookup(var.security_group_rule[count.index], "from_port_range")
  to_port_range   = lookup(var.security_group_rule[count.index], "to_port_range")
  ip_protocol     = lookup(var.security_group_rule[count.index], "ip_protocol")
  ip_range        = lookup(var.security_group_rule[count.index], "ip_range")

  dynamic "rules" {
    for_each = lookup(var.security_group_rule[count.index], "rules") == null ? [] : ["rules"]
    content {
      from_port_range = lookup(rules.value, "from_port_range")
      to_port_range   = lookup(rules.value, "to_port_range")
      ip_protocol     = lookup(rules.value, "ip_protocol")
      service_ids     = lookup(rules.value, "service_ids")

      dynamic "security_groups_members" {
        for_each = lookup(rules.value, "security_groups_members") == null ? [] : ["security_groups_members"]
        content {
          account_id          = lookup(security_groups_members.value, "account_id")
          security_group_name = lookup(security_groups_members.value, "security_group_name")
          security_group_id   = lookup(security_groups_members.value, "security_group_id")
        }
      }
    }
  }
}

resource "outscale_server_certificate" "this" {
  count       = length(var.server_certificate)
  name        = lookup(var.server_certificate[count.index], "name")
  body        = file(join("/", [path.cwd, "certificate", lookup(var.server_certificate[count.index], "body")]))
  chain       = file(join("/", [path.cwd, "certificate", lookup(var.server_certificate[count.index], "chain")]))
  path        = join("/", [path.cwd, "certificate"])
  private_key = file(join("/", [path.cwd, "certificate", lookup(var.server_certificate[count.index], "private_key")]))
}

resource "outscale_snapshot" "this" {
  count              = length(var.snapshot)
  description        = lookup(var.snapshot[count.index], "description")
  file_location      = lookup(var.snapshot[count.index], "file_location")
  snapshot_size      = lookup(var.snapshot[count.index], "snapshot_size")
  source_region_name = lookup(var.snapshot[count.index], "source_region_name")
  source_snapshot_id = lookup(var.snapshot[count.index], "source_snapshot_id")
  volume_id = try(
    element(outscale_volume.this.*.volume_id, lookup(var.snapshot[count.index], "volume_id"))
  )

  dynamic "tags" {
    for_each = lookup(var.snapshot[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_snapshot_attributes" "this" {
  count = length(var.snapshot) == 0 ? 0 : length(var.snapshot_attributes)
  snapshot_id = try(
    element(outscale_snapshot.this.*.snapshot_id, lookup(var.snapshot_attributes[count.index], "snapshot_id"))
  )

  dynamic "permissions_to_create_volume_additions" {
    for_each = lookup(var.snapshot_attributes[count.index], "permissions_to_create_volume_additions") == null ? [] : ["permissions_to_create_volume_additions"]
    content {
      account_ids       = lookup(permissions_to_create_volume_additions.value, "account_ids")
      global_permission = lookup(permissions_to_create_volume_additions.value, "global_permission")
    }
  }

  dynamic "permissions_to_create_volume_removals" {
    for_each = lookup(var.snapshot_attributes[count.index], "permissions_to_create_volume_removals") == null ? [] : ["permissions_to_create_volume_removals"]
    content {
      account_ids       = lookup(permissions_to_create_volume_removals.value, "account_ids")
      global_permission = lookup(permissions_to_create_volume_removals.value, "global_permission")
    }
  }
}

resource "outscale_snapshot_export_task" "this" {
  count = length(var.snapshot) == 0 ? 0 : length(var.snapshot_export_task)
  snapshot_id = try(
    element(outscale_snapshot.this.*.snapshot_id, lookup(var.snapshot_export_task[count.index], "snapshot_id"))
  )

  dynamic "osu_export" {
    for_each = lookup(var.snapshot_export_task[count.index], "osu_export") == null ? [] : ["osu_export"]
    content {
      disk_image_format = lookup(osu_export.value, "disk_image_format")
      osu_bucket        = lookup(osu_export.value, "osu_bucket")
      osu_prefix        = lookup(osu_export.value, "osu_prefix")

      dynamic "osu_api_key" {
        for_each = lookup(osu_api_key.value, "osu_api_key") == null ? [] : ["osu_api_key"]
        content {
          api_key_id = lookup(osu_api_key.value, "api_key_id")
          secret_key = lookup(osu_api_key.value, "secret_key")
        }
      }
    }
  }

  dynamic "tags" {
    for_each = lookup(var.snapshot_export_task[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_subnet" "this" {
  count    = length(var.net) == 0 ? 0 : length(var.subnet)
  ip_range = lookup(var.subnet[count.index], "ip_range")
  net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.subnet[count.index], "net_id"))
  )
  subregion_name = lookup(var.subnet[count.index], "subregion_name")

  dynamic "tags" {
    for_each = lookup(var.subnet[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_virtual_gateway" "this" {
  count           = length(var.virtual_gateway)
  connection_type = lookup(var.virtual_gateway[count.index], "connection_type")

  dynamic "tags" {
    for_each = lookup(var.virtual_gateway[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_virtual_gateway_link" "this" {
  count = (length(var.net) && length(var.virtual_gateway)) == 0 ? 0 : length(var.virtual_gateway_link)
  net_id = try(
    element(outscale_net.this.*.net_id, lookup(var.virtual_gateway_link[count.index], "net_id"))
  )
  virtual_gateway_id = try(
    element(outscale_virtual_gateway.this.*.virtual_gateway_id, lookup(var.virtual_gateway_link[count.index], "virtual_gateway_id"))
  )
}

resource "outscale_virtual_gateway_route_propagation" "this" {
  count  = (length(var.route_table) && length(var.virtual_gateway)) == 0 ? 0 : length(var.virtual_gateway_route_propagation)
  enable = lookup(var.virtual_gateway_route_propagation[count.index], "enable")
  route_table_id = try(
    element(outscale_route_table.this.*.route_table_id, lookup(var.virtual_gateway_route_propagation[count.index], "route_table_id"))
  )
  virtual_gateway_id = try(
    element(outscale_virtual_gateway.this.*.virtual_gateway_id, lookup(var.virtual_gateway_route_propagation[count.index], "virtual_gateway_id"))
  )
}

resource "outscale_vm" "this" {
  count = length(var.image) == 0 ? 0 : length(var.vm)
  image_id = try(
    element(outscale_image.this.*.image_id, lookup(var.vm[count.index], "image_id"))
  )
  deletion_protection = lookup(var.vm[count.index], "deletion_protection")
  get_admin_password  = lookup(var.vm[count.index], "get_admin_password")
  keypair_name = try(
    element(outscale_keypair.this.*.keypair_name, lookup(var.vm[count.index], "keypair_id"))
  )
  nested_virtualization    = lookup(var.vm[count.index], "nested_virtualization")
  performance              = lookup(var.vm[count.index], "performance")
  placement_subregion_name = lookup(var.vm[count.index], "placement_subregion_name")
  placement_tenancy        = lookup(var.vm[count.index], "placement_tenancy")
  private_ips = [
    try(
      element(outscale_nic_private_ip.this.*.private_ips, lookup(var.vm[count.index], "private_ips_id"))
    )
  ]
  security_group_ids = [
    try(
      element(outscale_security_group.this.*.security_group_id, lookup(var.vm[count.index], "security_group_ids"))
    )
  ]
  security_group_names = [
    try(
      element(outscale_security_group.this.*.security_group_name, lookup(var.vm[count.index], "security_group_ids"))
    )
  ]
  state = lookup(var.vm[count.index], "state")
  subnet_id = try(
    element(outscale_subnet.this.*.subnet_id, lookup(var.vm[count.index], "subnet_id"))
  )
  user_data                      = lookup(var.vm[count.index], "user_data")
  vm_initiated_shutdown_behavior = lookup(var.vm[count.index], "vm_initiated_shutdown_behavior")
  vm_type                        = lookup(var.vm[count.index], "vm_type")

  dynamic "block_device_mappings" {
    for_each = lookup(var.vm[count.index], "block_device_mappings") == null ? [] : ["block_device_mappings"]
    content {
      dynamic "bsu" {
        for_each = lookup(block_device_mappings.value, "bsu") == null ? [] : ["bsu"]
        content {
          delete_on_vm_deletion = lookup(bsu.value, "delete_on_vm_deletion")
          snapshot_id = try(
            element(outscale_snapshot.this.*.snapshot_id, lookup(bsu.value, "snapshot_id"))
          )
          iops        = lookup(bsu.value, "iops")
          volume_size = lookup(bsu.value, "volume_size")
          volume_type = lookup(bsu.value, "volume_type")
        }
      }
    }
  }

  dynamic "nics" {
    for_each = lookup(var.vm[count.index], "nics") == null ? [] : ["nics"]
    content {
      device_number         = lookup(nics.value, "device_number")
      delete_on_vm_deletion = lookup(nics.value, "delete_on_vm_deletion")
      description           = lookup(nics.value, "description")
      nic_id = try(
        element(outscale_nic.this.*.nic_id, lookup(nics.value, "nic_id"))
      )
      secondary_private_ip_count = lookup(nics.value, "secondary_private_ip_count")
      security_group_ids = [
        try(
          element(outscale_security_group.this.*.security_group_id, lookup(nics.value, "security_group_ids"))
        )
      ]
      subnet_id = try(
        element(outscale_subnet.this.*.subnet_id, lookup(nics.value, "subnet_id"))
      )

      dynamic "private_ips" {
        for_each = lookup(nics.value, "private_ips") == null ? [] : ["private_ips"]
        content {
          is_primary = lookup(private_ips.value, "is_primary")
          private_ip = lookup(private_ips.value, "is_primary") == true ? try(
            element(outscale_nic_private_ip.this.*.primary_private_ip, lookup(private_ips.value, "private_ip_id"))
          ) : null
        }
      }
    }
  }

  dynamic "tags" {
    for_each = lookup(var.vm[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_volume" "this" {
  count          = length(var.volume)
  subregion_name = lookup(var.volume[count.index], "subregion_name")
  iops           = lookup(var.volume[count.index], "iops")
  size           = lookup(var.volume[count.index], "size")
  snapshot_id = try(
    element(outscale_snapshot.this.*.snapshot_id, lookup(var.volume[count.index], "snapshot_id"))
  )
  volume_type = lookup(var.volume[count.index], "volume_type")

  dynamic "tags" {
    for_each = lookup(var.volume[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_volumes_link" "this" {
  count       = (length(var.vm) && length(var.volume)) == 0 ? 0 : length(var.volumes_link)
  device_name = lookup(var.volumes_link[count.index], "device_name")
  vm_id = try(
    element(outscale_vm.this.*.vm_id, lookup(var.volumes_link[count.index], "vm_id"))
  )
  volume_id = try(
    element(outscale_volume.this.*.volume_id, lookup(var.volumes_link[count.index], "volume_id"))
  )
}

resource "outscale_vpn_connection" "this" {
  count = (length(outscale_client_gateway) && length(var.virtual_gateway)) == 0 ? 0 : length(var.vpn_connection)
  client_gateway_id = try(
    element(outscale_client_gateway.this.*.client_gateway_id, lookup(var.vpn_connection[count.index], "client_gateway_id"))
  )
  connection_type = lookup(var.vpn_connection[count.index], "connection_type")
  virtual_gateway_id = try(
    element(outscale_virtual_gateway.this.*.virtual_gateway_id, lookup(var.vpn_connection[count.index], "virtual_gateway_id"))
  )
  static_routes_only = lookup(var.vpn_connection[count.index], "static_routes_only")

  dynamic "tags" {
    for_each = lookup(var.vpn_connection[count.index], "tags") == null ? [] : ["tags"]
    content {
      key   = lookup(tags.value, "key")
      value = lookup(tags.value, "value")
    }
  }
}

resource "outscale_vpn_connection_route" "this" {
  count                = length(var.vpn_connection) == 0 ? 0 : length(var.vpn_connection_route)
  destination_ip_range = lookup(var.vpn_connection_route[count.index], "destination_ip_range")
  vpn_connection_id = try(
    element(outscale_vpn_connection.this.*.vpn_connection_id, lookup(var.vpn_connection_route[count.index], "vpn_connection_id"))
  )
}
