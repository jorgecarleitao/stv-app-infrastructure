# STV App (stvote.eu) - infrastructure

This repository maintains the infrastructure of [stvote.eu](https://stvote.eu).

The source code of the application is at:

* [stv-app-infrastructure](https://github.com/jorgecarleitao/stv-app-infrastructure)
* [stv-app](https://github.com/jorgecarleitao/stv-app)
* [stv-app-frontend](https://github.com/jorgecarleitao/stv-app-frontend)

## Prerequisites

* Have a CloudFlare account with domain management access
* Have a Hetzner Cloud account
* Have a domain registered (e.g. Infomaniak) and migrated to CloudFlare

## Bootstrap (manual steps)

### 1. Hetzner Object Storage for Terraform State

1. Create a Hetzner project;
2. Create a Hetzner Object Storage bucket in a region and copy its name and location to `backend.hcl`;
3. Generate S3-compatible access credentials for `read+write` (Access Key + Secret Key) from Hetzner console and place them in `.env.private` (see below)
4. Create an API token in CloudFlare with permissions: `Zone:Read, DNS:Edit` permissions to `example.com`

and create a file `.env.private` with them

```
HCLOUD_TOKEN="..."
AWS_ACCESS_KEY_ID="..."
AWS_SECRET_ACCESS_KEY="..."
CLOUDFLARE_API_TOKEN="..."
```

### 2. SSH Keys for VM Access

Generate SSH key pairs for server access:

```bash
# GitHub Actions deployment key
ssh-keygen -t ed25519 -f ~/.ssh/hetzner_github_actions -C "github-actions@deploy"
```

### 3. Update Configuration

Change `configuration.yaml` with your specific values:

* `vm.key.operator`: your ssh public key
* `vm.key.github-actions`: contents of `~/.ssh/hetzner_github_actions.pub`
* `cloudflare.account_id`: your cloudflare account id
* `cloudflare.zones`: the domain you rented

Change `.env` with your information

### 4. Configure GitHub Actions Secrets

Add the following secrets to your GitHub repository (Settings -> Secrets and variables -> Actions):

- `SSH_PRIVATE_KEY`: Contents of `~/.ssh/hetzner_github_actions`
- `DOTENV_PRIVATE`: Contents of `.env.private`
