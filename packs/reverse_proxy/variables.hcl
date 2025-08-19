variable "admin_ip_cidrs" {
    default     = []
    description = "List of CIDR ranges allowed to access the Traefik admin/dashboard endpoints."
    type        = set(string)
}

variable "certificates_volume_id" {
    default     = "reverse_proxy-certificates"
    description = "ID of the CSI volume used to store and share TLS certificates for the ingress load balancer (Traefik)."
    type        = string
}

variable "dns_challenge" {
    description = "Configuration for DNS-01 ACME challenge used by Traefik. More info @ https://go-acme.github.io/lego/dns/."
    type = object({
        email     = string
        provider  = string
        variables = map(string)
    })
}

variable "id" {
    description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
    type        = string
}

variable "log_level" {
    default     = "INFO"
    description = "Log verbosity for the Traefik process (e.g., PANIC, FATAL, ERROR, WARN, INFO, DEBUG)."
    type        = string
}

variable "traefik_hostname" {
    description = "The hostname (FQDN) used to access the Traefik dashboard. This is the domain that Traefik will serve its web UI on."
    type        = string
}

variable "traefik_version" {
    default     = "3.5.0"
    description = "Container image version tag for the Traefik (maps to `traefik:v<version>`)."
    type        = string
}
