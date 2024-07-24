run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "access_key_creation" {
    command = [plan,apply]

    variables {
        access_key = [
            {
                id              = 0
                state           = "ACTIVE"
                expiration_date = "2024-07-24"
            },
            {
                id              = 1
                state           = "INACTIVE"
                expiration_date = "2023-07-24"
            }
        ]
    }
}

run "image_creation" {
    command = [plan,apply]

    variables {
        image = [
            {
                id                  = 0
                image_name          = "terraform-omi-bsu"
                root_device_name    = "/dev/sda1"
                description         = "Terraform OMI with BSU"
                block_device_mappings = [
                    {
                    device_name = "/dev/sda1"
                    bsu = [
                            {
                            snapshot_id           = "snap-12345678"
                            volume_size           = "120"
                            volume_type           = "io1"
                            iops                  = 150
                            delete_on_vm_deletion = "true"
                            }
                        ]
                    }
                ]
            },
            {
                id            = 1
                description   = "Terraform register OMI"
                image_name    = "terraform-omi-register"
                file_location = "<URL>"
            }
        ]
    }
}

run "load_balancer_creation" {
    command = [plan,apply]

    variables {
        net = [
            {
                id          = 0
                ip_range    = "10.0.0.0/16"
            }
        ]
        subnet = [
            {
                id       = 0
                net_id   = 0
                ip_range = "10.0.0.0/24"
                tags = [
                    {
                        key   = "Name"
                        value = "terraform-subnet-for-internal-load-balancer"
                    }
                ]
            }
        ]
        security_group = [
            {
                id                  = 0
                description         = "Terraform security group for internal load balancer"
                security_group_name = "terraform-security-group-for-internal-load-balancer"
                net_id              = 0
                tags = [
                    {
                        key   = "Name"
                        value = "terraform-security-group-for-internal-load-balancer"
                    }
                ]
            }
        ]
        security_group_rule = [
            {
                id                = 0
                flow              = "Inbound"
                security_group_id = 0
                from_port_range   = "80"
                to_port_range     = "80"
                ip_protocol       = "tcp"
                ip_range          = "10.0.0.0/16"
            }
        ]
        key_pair = [
            {
                id           = 0
                keypair_name = "terraform-keypair-for-vm"
            }
        ]
        vm = [
            {
                id = 0
                image_id                = 0
                vm_type                 = var.vm_type
                keypair_name            = 0
                security_group_ids      = [0]
                subnet_id               = 0
                block_device_mappings = [
                    {
                        device_name = "/dev/sda1" # /dev/sda1 corresponds to the root device of the VM
                        bsu = [
                            {
                                volume_size = 15
                                volume_type = "gp2"
                            }
                        ]
                    }
                ]
            }
        ]
    }
}