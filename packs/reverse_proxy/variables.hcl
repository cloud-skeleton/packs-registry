variable "id" {
  description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
  type        = string
}

variable "traefik_version" {
  default     = "3.5.0"
  description = "Container image version tag for the Traefik (maps to `traefik:v<version>`)."
  type        = string
}

variable "certificates_volume_id" {
  default     = "reverse_proxy-certificates"
  description = "ID of the CSI volume used to store and share TLS certificates for the ingress load balancer (Traefik)."
  type        = string
}

variable "admin_ip_cidrs" {
  default     = []
  description = "List of CIDR ranges allowed to access the Traefik admin/dashboard endpoints."
  type        = set(string)
}