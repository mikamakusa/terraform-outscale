output "access_key_id" {
  value = try(
    outscale_access_key.this.*.access_key_id
  )
  description = "The ID of the access key"
}

output "api_access_rule_id" {
  value = try(
    outscale_api_access_rule.this.*.api_access_rule_id
  )
  description = "The ID of the API access rule"
}

output "client_gateway_id" {
  value = try(
    outscale_client_gateway.this.*.client_gateway_id
  )
  description = "The ID of the client gateway"
}

output "ca_id" {
  value = try(
    outscale_ca.this.*.ca_id
  )
  description = "The ID of the CA"
}

output "dhcp_options_set_id" {
  value = try(
    outscale_dhcp_option.this.*.dhcp_options_set_id
  )
  description = "The ID of the DHCP options set"
}

output "flexible_gpu_id" {
  value = try(
    outscale_flexible_gpu.this.*.flexible_gpu_id
  )
  description = "The ID of the fGPU"
}

output "image_id" {
  value = try(
    outscale_image.this.*.image_id
  )
  description = "The ID of the OMI"
}

output "internet_service_id" {
  value = try(
    outscale_internet_service.this.*.internet_service_id
  )
  description = "The ID of the Internet service"
}

output "keypair_name" {
  value = try(
    outscale_keypair.this.*.keypair_name
  )
  description = "The name of the keypair."
}

output "load_balancer_name" {
  value = try(
    outscale_load_balancer.this.*.load_balancer_name
  )
  description = "The name of the load balancer."
}

output "nat_service_id" {
  value = try(
    outscale_nat_service.this.*.nat_service_id
  )
  description = "The ID of the NAT service"
}

output "net_id" {
  value = try(
    outscale_net.this.*.net_id
  )
  description = "The ID of the Net"
}

output "nic_id" {
  value = try(
    outscale_nic.this.*.nic_id
  )
  description = "The ID of the NIC"
}

output "public_ip" {
  value = try(
    outscale_public_ip.this.*.public_ip
  )
  description = "The public IP"
}

output "public_ip_id" {
  value = try(
    outscale_public_ip.this.*.public_ip_id
  )
  description = "The allocation ID of the public IP"
}

output "route_table_id" {
  value = try(
    outscale_route_table.this.*.route_table_id
  )
  description = "The ID of the route table"
}

output "security_group_id" {
  value = try(
    outscale_security_group.this.*.security_group_id
  )
  description = "The ID of the security group"
}

output "snapshot_id" {
  value = try(
    outscale_snapshot.this.*.snapshot_id
  )
  description = "The IDs of the snapshots"
}

output "subnet_id" {
  value = try(
    outscale_subnet.this.*.subnet_id
  )
  description = "The IDs of the Subnets"
}

output "volume_id" {
  value = try(
    outscale_volume.this.*.volume_id
  )
  description = "The ID of the volume"
}

output "vpn_connection_id" {
  value = try(
    outscale_vpn_connection.this.*.vpn_connection_id
  )
  description = "The ID of the VPN connection"
}