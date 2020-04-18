# terraform-jitsi

## Overview

The contents of this repo deploys an instance of [Jitsi Meet](https://jitsi.org/jitsi-meet/) to an OpenStack environment accessible at a URL (for which the DNS is managed by Cloudflare). It assumes you already have generated a valid X.509 certificate and wish to prevent anonymous users from creating new meeting rooms.

There are two main methods for deployment, for which there are two directories:

- **publicnetwork**: This creates a port on the specified openstack_network and therefore does not create an internal network; the instance is directly exposed. This requires that the openstack_network is a shared network.
- **privatenetwork**: This creates a network which is connected to the specified openstack_router_name (it assumes one has already been created and the name is known). It then provisions a floating IP on the specified openstack_network to enable ingress traffic. This deployment method is preferred when the openstack_network is not a shared network.

To deploy:

You will need to download and source your OpenStack RC File (v3) for the relevant environment.

```
terraform init
terraform apply
```

This has been tested with the following version of Terraform and utilised providers:

>- Terraform v0.12.24
>- provider.cloudflare v2.5.1
>- provider.openstack v1.26.0

## Requirements

All secrets should be substituted into `terraform.tfvars`

- `domain`: The URL your Jitsi meet server will be accessible at
- `ssh_ingress_ip`: The CIDR block to add to the SSH rule in the OpenStack security group (set this to 0.0.0.0/0 to allow all inbound traffic)
- `ssh_path`: A path to the desired SSH keypair to be used for accessing the instance (you can generate one with `ssh-keygen -t rsa -b 4096 -C "jitsi" -f ~/.ssh/jitsi`)
- `certificate_path`: A path to the desired X.509 certificate for the Jitsi meet server
- `jitsi_user_name`: The username to authenticate with when creating new meeting rooms
- `jitsi_password`: The password to authenticate with when creating new meeting rooms

### OpenStack

- `openstack_network`: The external network to expose the instance to
- `openstack_router_name`: Only applicable when using the privatenetwork deployment method, this should be the name of an existing router in the project you are deploying to
- `openstack_image`: The instance image to use (Operating System)
- `openstack_flavor`: The instance flavor to use (Instance hardware configuration)
- `openstack_resource_name`: Defaults to "jitsi" and is commented out, uncomment and specify the desired name if preferred.

### Cloudflare
- `cloudflare_api_token`: API token generated through Cloudflare Dashboard
- `cloudflare_zone_id`: Zone ID for desired domain retrieved from [Cloudflare API](https://api.cloudflare.com/#getting-started-endpoints)
