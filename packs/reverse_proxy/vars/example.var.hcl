# CSI volume object used to store and share TLS certificates for the ingress load balancer (Traefik).
certificates_volume = {
    id        = "reverse_proxy-certificates"
    name      = "reverse_proxy/certificates"
    plugin_id = "nas"
}

# The hostname (FQDN) used to access the Traefik dashboard. This is the domain that Traefik will serve its web UI on.
hostname = "lb.cluster.domain.com"

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"