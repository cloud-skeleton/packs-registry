variable "id" {
    description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
    type        = string
}

variable "parameters_meta_prefix" {
    default     = "params"
    description = "Metadata prefix to be used as parameter defaults."
    type        = string
}

variable "parameters_root_path" {
    default     = "params"
    description = "Root path in Nomad variables (e.g. params/...) managed by the watchdog service."
    type        = string
}

variable "watchdog_version" {
    default     = "1.1"
    description = "Container image version tag for job watchdog (maps to `ghcr.io/cloud-skeleton/nomad-job-watchdog:v<version>`)."
    type        = string
}