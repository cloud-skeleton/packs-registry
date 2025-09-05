variable "admin_ip_cidrs" {
    default     = []
    description = "List of CIDR ranges allowed to access the Traefik admin/dashboard endpoints."
    type        = set(string)
}

variable "certificates_volume" {
    description = "CSI volume object used to store and share TLS certificates for the ingress load balancer (Traefik)."
    type = object({
        id        = string
        name      = string
        plugin_id = string
    })
}

variable "id" {
    description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
    type        = string
}

variable "log_level" {
    default     = "INFO"
    description = "[Soft] Log verbosity for the Traefik process (e.g., PANIC, FATAL, ERROR, WARN, INFO, DEBUG)."
    type        = string
}

variable "traefik_hostname" {
    description = "The hostname (FQDN) used to access the Traefik dashboard. This is the domain that Traefik will serve its web UI on."
    type        = string
}

variable "traefik_version" {
    default     = "3.5.1"
    description = "[Soft] Container image version tag for the Traefik (maps to `traefik:v<version>`)."
    type        = string
}
