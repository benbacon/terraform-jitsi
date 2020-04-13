variable "image" {
    default = "Debian 10"
}

variable "flavor" {
    # Production flavor
    default = "b2-7"
    # Testing flavor
    #default = "s1-2"
}

variable "network" {
    default = "Ext-Net"
}

variable "auth_url" {
    default = "https://auth.cloud.ovh.net/v3"
}

variable "ssh_path" {
    default = "~/.ssh/jitsi"
}

variable "domain" {

}

variable "ssh_ingress_ip" {

}

variable "certificate_path" {

}

variable "jitsi_user_name" {
}

variable "jitsi_password" {

}

variable "openstack_user_name" {

}

variable "openstack_tenant_name" {

}

variable "openstack_password" {

}

variable "openstack_region" {

}

variable "cloudflare_api_token" {

}

variable "cloudflare_zone_id" {

}
