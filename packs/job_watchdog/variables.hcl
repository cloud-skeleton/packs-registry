variable "watchdog_version" {
    default     = "1.0"
    description = "Container image version tag for job watchdog (maps to `ghcr.io/cloud-skeleton/nomad-job-watchdog:v<version>`)."
    type        = string
}

variable "id" {
    description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
    type        = string
}