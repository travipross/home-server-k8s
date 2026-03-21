# Cloudflared

Deploys `cloudflared` agent, connected to a Remotely Managed Cloudflare tunnel, configured via Terraform (See [terraform script](../../terraform/tunnels.tf) for more information).

See Cloudflare Docs for Kubernetes Deployment of `cloudflared`: [Link](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/deployment-guides/kubernetes/#_top)

## Obtaining Tunnel Token

As an alternative to obtaining the token from Cloudflare One, the token can be obtained from Terraform output.

```bash
# Navigate to terraform directory
cd ../../terraform

# Output raw token value
terraform output -raw tunnel_token
```

After obtaining the token, replace the SOPS-encrypted secret [here](terraform-tunnel-token-secret.enc.yaml) as described by the [README](../../README.md#encrypting-secrets), and commit the changes.
