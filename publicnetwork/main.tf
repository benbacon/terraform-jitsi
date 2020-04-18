provider "openstack" {

}

provider "cloudflare" {
    api_token = var.cloudflare_api_token
}

resource "openstack_compute_keypair_v2" "jitsi" {
    name = var.openstack_resource_name
    public_key = file("${var.ssh_path}.pub")
}

resource "openstack_networking_secgroup_v2" "jitsi" {
    name = var.openstack_resource_name
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

resource "openstack_networking_secgroup_rule_v2" "jitsi_rtp_udp" {
    description = "Allow RTP UDP traffic"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "udp"
    port_range_min = 10000
    port_range_max = 10000
    security_group_id = openstack_networking_secgroup_v2.jitsi.id
}

resource "openstack_networking_secgroup_rule_v2" "jitsi_icmp" {
    description = "Allow ICMP traffic"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "icmp"
    port_range_min = 8
    port_range_max = 0
    security_group_id = openstack_networking_secgroup_v2.jitsi.id
}

resource "openstack_compute_instance_v2" "jitsi" {
    name = var.openstack_resource_name
    image_name = var.openstack_image
    flavor_name = var.openstack_flavor
    key_pair = openstack_compute_keypair_v2.jitsi.name
    security_groups = [ openstack_networking_secgroup_v2.jitsi.name ]
    user_data = templatefile( "${path.module}/install_jitsi.tpl", { domain = var.domain, certificate = file("${var.certificate_path}/fullchain.pem"), key = file("${var.certificate_path}/privkey.pem"), jitsi_user_name = var.jitsi_user_name, jitsi_password = var.jitsi_password } )

    network {
        name = var.openstack_network
    }

}

resource "cloudflare_record" "jitsi" {
    zone_id = var.cloudflare_zone_id
    name = var.domain
    value = openstack_compute_instance_v2.jitsi.access_ip_v4
    type = "A"
    proxied = false
    ttl = 1
}
