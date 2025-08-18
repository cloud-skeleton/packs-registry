variable "id" {
  description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
  type        = string
}

variable "log_level" {
  default     = "INFO"
  description = "Log verbosity for the CSI plugin process (e.g., CRITICAL, ERROR, WARNING, INFO, DEBUG)."
  type        = string
}

variable "nfs_share" {
  description = "NFS server (hostname/IP) or export to use as the backing store, e.g., nas.lan:/export/nomad."
  type        = string
}

variable "plugin_version" {
  default     = "1.1.0"
  description = "Container image version tag for the CSI plugin (maps to `registry.gitlab.com/rocketduck/csi-plugin-nfs:<version>`)."
  type        = string
}
