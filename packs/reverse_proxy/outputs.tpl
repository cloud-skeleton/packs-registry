Configure your DNS-01 challenge provider credentials via nomad/jobs/[[ template "job_name" (list . "ingress_load_balancer") ]]/traefik/service variable:
---
nomad var put -force -namespace=system nomad/jobs/[[ template "job_name" (list . "ingress_load_balancer") ]]/traefik/service \
    AWS_ACCESS_KEY_ID="your_key_id" \
    AWS_SECRET_ACCESS_KEY="your_secret_access_key" \
    AWS_REGION="aws-region" \
    AWS_HOSTED_ZONE_ID="your_hosted_zone_id"

More info about available variables can be found at https://go-acme.github.io/lego/dns/index.html
