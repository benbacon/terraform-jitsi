provider "openstack" {
    user_name = var.openstack_user_name
    tenant_name = var.openstack_tenant_name
    password = var.openstack_password
    auth_url = var.auth_url
    region = var.openstack_region
}

provider "cloudflare" {
    api_token = var.cloudflare_api_token
}

resource "openstack_compute_keypair_v2" "jitsi" {
    name = "jitsi"
    public_key = file("${var.ssh_path}.pub")
}

resource "openstack_networking_secgroup_v2" "jitsi" {
  name = "jitsi"
}

resource "openstack_networking_secgroup_rule_v2" "jitsi_ssh" {
    description = "Allow SSH traffic"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 22
    port_range_max = 22
    remote_ip_prefix = var.ssh_ingress_ip
    security_group_id = openstack_networking_secgroup_v2.jitsi.id
}

resource "openstack_networking_secgroup_rule_v2" "jitsi_http" {
    description = "Allow HTTP traffic"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 80
    port_range_max = 80
    security_group_id = openstack_networking_secgroup_v2.jitsi.id
}

resource "openstack_networking_secgroup_rule_v2" "jitsi_https" {
    description = "Allow HTTPS traffic"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 443
    port_range_max = 443
    security_group_id = openstack_networking_secgroup_v2.jitsi.id
}

resource "openstack_networking_secgroup_rule_v2" "jitsi_rtp_tcp" {
    description = "Allow RTP TCP traffic"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 4443
    port_range_max = 4443
    security_group_id = openstack_networking_secgroup_v2.jitsi.id
}

resource "openstack_networking_secgroup_rule_v2" "jitsi_rtp_udp" {
    description = "Allow RTP UDP traffic"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "udp"
    port_range_min = 10000
    port_range_max = 10000
    security_group_id = openstack_networking_secgroup_v2.jitsi.id
}

resource "openstack_compute_instance_v2" "jitsi" {
  name = "jitsi"
  image_name = var.image
  flavor_name = var.flavor
  key_pair = "jitsi"
  security_groups = ["jitsi"]
  user_data = templatefile( "${path.module}/install_jitsi.tpl", { domain = var.domain, certificate = file("${var.certificate_path}/fullchain.pem"), key = file("${var.certificate_path}/privkey.pem"), jitsi_user_name = var.jitsi_user_name, jitsi_password = var.jitsi_password } )

  network {
    name = var.network
  }

}

resource "cloudflare_record" "jitsi" {
    zone_id = var.cloudflare_zone_id
    name = "jitsi"
    value = openstack_compute_instance_v2.jitsi.access_ip_v4
    type = "A"
    proxied = false
    ttl = 1
}
