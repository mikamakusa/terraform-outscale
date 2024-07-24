variable "data_image" {
  type    = string
  default = null
}

variable "access_key" {
  type = list(object({
    id              = number
    expiration_date = optional(string)
    state           = optional(string)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "api_access_policy" {
  type = list(object({
    id                                = number
    max_access_key_expiration_seconds = number
    require_trusted_env               = bool
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "api_access_rule" {
  type = list(object({
    id          = number
    ca_ids      = optional(set(string))
    cns         = optional(set(string))
    description = optional(string)
    ip_ranges   = optional(set(string))
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "ca" {
  type = list(object({
    id          = number
    ca_pem      = optional(string)
    description = optional(string)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "client_gateway" {
  type = list(object({
    id              = number
    bgp_asn         = number
    connection_type = string
    public_ip       = any
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "dhcp_option" {
  type = list(object({
    id                  = number
    domain_name         = optional(string)
    domain_name_servers = optional(list(string))
    log_servers         = optional(list(string))
    ntp_servers         = optional(list(string))
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "flexible_gpu" {
  type = list(object({
    id                    = number
    model_name            = string
    subregion_name        = string
    delete_on_vm_deletion = optional(bool)
    generation            = optional(string)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "flexible_gpu_link" {
  type = list(object({
    id              = number
    flexible_gpu_id = number
    vm_id           = number
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "image" {
  type = list(object({
    id                 = number
    architecture       = optional(string)
    description        = optional(string)
    file_location      = optional(string)
    image_name         = optional(string)
    no_reboot          = optional(bool)
    root_device_name   = optional(string)
    source_image_id    = optional(string)
    source_region_name = optional(string)
    vm_id              = optional(any)
    block_device_mappings = optional(list(object({
      device_name         = optional(string)
      virtual_device_name = optional(string)
      bsu = optional(list(object({
        delete_on_vm_deletion = optional(bool)
        iops                  = optional(number)
        snapshot_id           = optional(any)
        volume_size           = optional(number)
        volume_type           = optional(string)
      })), [])
    })), [])
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "image_export_task" {
  type = list(object({
    id       = number
    image_id = optional(any)
    osu_export = optional(list(object({
      disk_image_format = string
      osu_bucket        = string
      osu_manifest_url  = optional(string)
      osu_prefix        = optional(string)
      osu_api_key = optional(list(object({
        api_key_id = string
        secret_key = string
      })), [])
    })), [])
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "image_launch_permission" {
  type = list(object({
    id       = number
    image_id = optional(any)
    permission_additions = optional(list(object({
      account_ids       = optional(list(string))
      global_permission = optional(string)
    })), [])
    permission_removals = optional(list(object({
      account_ids       = optional(list(string))
      global_permission = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "internet_service" {
  type = list(object({
    id = number
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "internet_service_link" {
  type = list(object({
    id                  = number
    internet_service_id = optional(any)
    net_id              = optional(any)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "keypair" {
  type = list(object({
    id           = number
    keypair_name = optional(string)
    public_key   = optional(string)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "load_balancer" {
  type = list(object({
    id                 = number
    load_balancer_name = string
    load_balancer_type = optional(string)
    public_ip_id       = optional(any)
    security_groups_id = optional(list(any))
    subnets_id         = optional(list(any))
    subregion_names    = optional(list(string))
    listeners = optional(list(object({
      backend_port           = number
      backend_protocol       = string
      load_balancer_port     = number
      load_balancer_protocol = string
      server_certificate_id  = optional(string)
    })), [])
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "load_balancer_attributes" {
  type = list(object({
    id                    = number
    load_balancer_id      = number
    load_balancer_port    = optional(number)
    policy_id             = optional(any)
    server_certificate_id = optional(string)
    access_log = optional(list(object({
      is_enabled           = optional(bool)
      osu_bucket_name      = optional(string)
      osu_bucket_prefix    = optional(string)
      publication_interval = optional(number)
    })), [])
    health_check = optional(list(object({
      check_interval      = number
      healthy_threshold   = number
      port                = number
      protocol            = string
      timeout             = number
      unhealthy_threshold = number
    })), [])
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "load_balancer_listener_rule" {
  type = list(object({
    id     = number
    vm_ids = optional(list(any))
    listener = optional(list(object({
      load_balancer_id   = any
      load_balancer_port = number
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "load_balancer_policy" {
  type = list(object({
    id               = number
    load_balancer_id = any
    policy_name      = string
    policy_type      = string
    cookie_name      = optional(string)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "load_balancer_vms" {
  type = list(object({
    id               = number
    backend_vm_ids   = list(any)
    load_balancer_id = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "nat_service" {
  type = list(object({
    id           = number
    public_ip_id = any
    subnet_id    = any
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "net" {
  type = list(object({
    id       = number
    ip_range = string
    tenancy  = string
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "net_access_point" {
  type = list(object({
    id              = number
    net_id          = any
    service_name    = string
    route_table_ids = optional(list(any))
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "net_attributes" {
  type = list(object({
    id                  = number
    net_id              = any
    dhcp_options_set_id = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "net_peering" {
  type = list(object({
    id              = number
    accepter_net_id = any
    source_net_id   = any
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "net_peering_acceptation" {
  type = list(object({
    id             = number
    net_peering_id = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "nic" {
  type = list(object({
    id                 = number
    subnet_id          = any
    description        = optional(string)
    private_ip         = optional(string)
    security_group_ids = optional(list(any))
    private_ips = optional(list(object({
      is_primary = optional(bool)
      private_ip = optional(string)
    })), [])
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "nic_link" {
  type = list(object({
    id            = number
    device_number = number
    nic_id        = any
    vm_id         = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "nic_private_ip" {
  type = list(object({
    id                         = number
    nic_id                     = any
    allow_relink               = optional(bool)
    private_ips                = optional(list(string))
    secondary_private_ip_count = optional(number)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "public_ip" {
  type = list(object({
    id = number
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "public_ip_link" {
  type = list(object({
    id           = number
    allow_relink = optional(bool)
    nic_id       = optional(any)
    private_ip   = optional(any)
    public_ip_id = optional(any)
    vm_id        = optional(any)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "route" {
  type = list(object({
    id                   = number
    destination_ip_range = string
    route_table_id       = any
    await_active_state   = optional(bool)
    nat_service_id       = optional(any)
    net_peering_id       = optional(any)
    nic_id               = optional(any)
    vm_id                = optional(any)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "route_table" {
  type = list(object({
    id     = number
    net_id = any
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "route_table_link" {
  type = list(object({
    id             = number
    route_table_id = any
    subnet_id      = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "security_group" {
  type = list(object({
    id                           = number
    description                  = optional(string)
    net_id                       = optional(any)
    remove_default_outbound_rule = optional(bool)
    security_group_name          = optional(any)
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "security_group_rule" {
  type = list(object({
    id                = number
    flow              = string
    security_group_id = any
    from_port_range   = optional(number)
    to_port_range     = optional(number)
    ip_protocol       = optional(string)
    ip_range          = optional(string)
    rules = optional(list(object({
      from_port_range = optional(number)
      to_port_range   = optional(number)
      ip_protocol     = optional(string)
      service_ids     = optional(list(any))
      security_groups_members = optional(list(object({
        account_id        = optional(any)
        security_group_id = optional(any)
      })), [])
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "server_certificate" {
  type = list(object({
    id          = number
    name        = string
    body        = optional(string)
    chain       = optional(string)
    path        = optional(string)
    private_key = optional(string)
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "snapshot" {
  type = list(object({
    id                 = number
    description        = optional(string)
    file_location      = optional(string)
    snapshot_size      = optional(number)
    source_region_name = optional(string)
    source_snapshot_id = optional(string)
    volume_id          = optional(any)
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "snapshot_attributes" {
  type = list(object({
    id          = number
    snapshot_id = any
    permissions_to_create_volume_additions = optional(list(object({
      account_ids       = optional(list(any))
      global_permission = optional(bool)
    })), [])
    permissions_to_create_volume_removals = optional(list(object({
      account_ids       = optional(list(any))
      global_permission = optional(bool)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "snapshot_export_task" {
  type = list(object({
    id          = number
    snapshot_id = any
    osu_export = optional(list(object({
      disk_image_format = string
      osu_bucket        = string
      osu_prefix        = optional(string)
      osu_api_key = optional(list(object({
        api_key_id = string
        secret_key = string
      })), [])
    })), [])
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "subnet" {
  type = list(object({
    id             = number
    ip_range       = string
    net_id         = any
    subregion_name = optional(string)
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "virtual_gateway" {
  type = list(object({
    id              = number
    connection_type = string
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "virtual_gateway_link" {
  type = list(object({
    id                 = number
    net_id             = any
    virtual_gateway_id = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "virtual_gateway_route_propagation" {
  type = list(object({
    id                 = number
    enable             = bool
    route_table_id     = any
    virtual_gateway_id = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "vm" {
  type = list(object({
    id                             = number
    image_id                       = any
    deletion_protection            = optional(bool)
    get_admin_password             = optional(bool)
    keypair_id                     = optional(any)
    nested_virtualization          = optional(bool)
    performance                    = optional(string)
    placement_subregion_name       = optional(string)
    placement_tenancy              = optional(string)
    private_ips_id                 = optional(list(any))
    security_group_ids             = optional(list(any))
    state                          = optional(string)
    subnet_id                      = optional(any)
    user_data                      = optional(string)
    vm_initiated_shutdown_behavior = optional(string)
    vm_type                        = optional(string)
    block_device_mappings = optional(list(object({
      bsu = optional(list(object({
        delete_on_vm_deletion = optional(bool)
        snapshot_id           = optional(any)
        iops                  = optional(number)
        volume_size           = optional(number)
        volume_type           = optional(string)
      })), [])
    })), [])
    nics = optional(list(object({
      device_number              = optional(number)
      delete_on_vm_deletion      = optional(bool)
      description                = optional(string)
      nic_id                     = optional(any)
      secondary_private_ip_count = optional(number)
      security_group_ids         = optional(list(any))
      subnet_id                  = optional(any)
      private_ips = optional(list(object({
        is_primary = bool
        private_ip = any
      })), [])
    })), [])
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "volume" {
  type = list(object({
    id             = number
    subregion_name = string
    iops           = optional(number)
    size           = optional(number)
    snapshot_id    = optional(any)
    volume_type    = optional(string)
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "volumes_link" {
  type = list(object({
    id          = number
    device_name = string
    vm_id       = any
    volume_id   = any
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "vpn_connection" {
  type = list(object({
    id                 = number
    client_gateway_id  = any
    connection_type    = string
    virtual_gateway_id = any
    static_routes_only = optional(bool)
    tags = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "vpn_connection_route" {
  type = list(object({
    id                   = number
    destination_ip_range = string
    vpn_connection_id    = any
  }))
  default     = []
  description = <<EOF
    EOF
}
