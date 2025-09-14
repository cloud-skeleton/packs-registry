variable "certificates_volume" {
    description = "CSI volume object used to store and share TLS certificates for the ingress load balancer (Traefik)."
    type = object({
        id        = string
        name      = string
        plugin_id = string
    })
}

variable "hostname" {
    description = "The hostname (FQDN) used to access the Traefik dashboard. This is the domain that Traefik will serve its web UI on."
    type        = string
}

variable "id" {
    description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
    type        = string
}