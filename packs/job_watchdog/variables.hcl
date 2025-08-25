variable "autoacl_version" {
    default     = "1.0"
    description = "Container image version tag for the autoACL (maps to `ghcr.io/cloud-skeleton/nomad-job-var-autoacl:v<version>`)."
    type        = string
}

variable "id" {
    description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
    type        = string
}