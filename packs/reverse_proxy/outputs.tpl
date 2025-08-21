Configure your DNS-01 challenge provider credentials via nomad/jobs/[[ meta "pack.name" . ]]-ingress_load_balancer-[[ var "id" . ]]/traefik/service variable:
---
nomad var put -force -namespace=system nomad/jobs/[[ meta "pack.name" . ]]-ingress_load_balancer-[[ var "id" . ]]/traefik/service \
    AWS_ACCESS_KEY_ID="your_key_id" \
    AWS_SECRET_ACCESS_KEY="your_secret_access_key" \
    AWS_REGION="aws-region" \
    AWS_HOSTED_ZONE_ID="your_hosted_zone_id"

More info about available variables can be found at https://go-acme.github.io/lego/dns/index.html
