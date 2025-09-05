admin_ip_cidrs = []
certificates_volume = {
    id        = "reverse_proxy-certificates"
    name      = "reverse_proxy/certificates"
    plugin_id = "nas"
}
id               = "main"
log_level        = "INFO"
traefik_hostname = "lb.cluster.domain.com"
traefik_version  = "3.5.1"