1. Allow Traefik to access Nomad job information:
cat << POLICY | nomad acl policy apply -namespace system -job [[ template "job_name" (list . "ingress_load_balancer") ]] \
    -description "Allow Traefik read access to Jobs" allow-traefik-jobs-read -
namespace "*" {
    capabilities = ["read-job"]
}
POLICY

2. Configure DNS-01 challenge provider credentials:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "ingress_load_balancer") ]]/dns \
    CODE="route53" \
    AWS_ACCESS_KEY_ID="your_key_id" \
    AWS_SECRET_ACCESS_KEY="your_secret_access_key" \
    AWS_REGION="aws-region" \
    AWS_HOSTED_ZONE_ID="your_hosted_zone_id"

More info about available variables can be found at https://go-acme.github.io/lego/dns/index.html
