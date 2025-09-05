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

variable "volumes_meta_prefix" {
    default     = "volumes"
    description = "Metadata prefix to be used as volumes configuration."
    type        = string
}
