# terraform-jitsi

## Overview

The contents of this repo deploys an instance of [Jitsi Meet](https://jitsi.org/jitsi-meet/) to an OpenStack environment accessible at a URL (for which the DNS is managed by Cloudflare). It assumes you already have generated a valid X.509 certificate and wish to prevent anonymous users from creating new meeting rooms.

To deploy:

```
terraform init
terraform apply
```

This has been tested with the following version of Terraform and utilised providers:

>- Terraform v0.12.24
>- provider.cloudflare v2.5.1
>- provider.openstack v1.26.0

## Requirements

> There are some default values set in `variables.tf` which may not be valid depending on which OpenStack environment you deploy to. These default values are for:
> - `image`: The instance image to use (Operating System)
> - `flavor`: The instance flavor to use (Instance hardware configuration)
> - `network`: The network to attach the instance to
> - `auth_url`: The authentication URL for your OpenStack environment
> - `ssh_path`: A path to the desired SSH keypair to be used for accessing the instance (you can generate one with `ssh-keygen -t rsa -b 4096 -C "jitsi" -f ~/.ssh/jitsi`)

All remaining secrets should be substituted into `terraform.tfvars`

- `domain`: The URL your Jitsi meet server will be accessible at
- `ssh_ingress_ip`: The CIDR block to add to the SSH rule in the OpenStack security group (set this to 0.0.0.0/0 to allow all inbound traffic)
- `certificate_path`: A path to the desired X.509 certificate for the Jitsi meet server
- `jitsi_user_name`: The username to authenticate with when creating new meeting rooms
- `jitsi_password`: The password to authenticate with when creating new meeting rooms

### OpenStack credentials

- `openstack_user_name`
- `openstack_tenant_name`
- `openstack_password`
- `openstack_region`

### Cloudflare
- `cloudflare_api_token`: API token generated through Cloudflare Dashboard
- `cloudflare_zone_id`: Zone ID for desired domain retrieved from [Cloudflare API](https://api.cloudflare.com/#getting-started-endpoints)
