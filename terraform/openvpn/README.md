# OpenVPN

Provision an OpenVPN server on DigitalOcean.

## Setup

Create a [personal access token](https://docs.digitalocean.com/reference/api/create-personal-access-token/) with the following custom scope:

| Resource | Scope |
| -------- | ----- |
| droplet  | all   |
| firewall | all   |
| ssh_key  | read  |

Add the token as an environment variable:

```shell
read -s "TF_VAR_do_token?Token: "
export TF_VAR_do_token
```

## Usage

```shell
terraform plan -out openvpn.tfplan
terraform apply openvpn.tfplan
```

```shell
terraform destroy -auto-approve
```
