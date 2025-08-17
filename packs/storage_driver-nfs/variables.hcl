variable "log_level" {
  default     = "INFO"
  description = "Log verbosity for the CSI plugin process (e.g., TRACE, DEBUG, INFO, WARN, ERROR)."
  type        = string
}

variable "namespace" {
  default     = "system"
  description = "Nomad namespace to submit this system job into. Use an existing namespace (e.g., 'system'); if namespaces aren't configured, use 'default'."
  type        = string
}

variable "nfs_share" {
  description = "NFS server (hostname/IP) or export to use as the backing store, e.g., nas.lan:/export/nomad."
  type        = string
}

variable "node_class" {
  default     = "main-worker"
  description = "Nomad node class to target (matches node attribute `node.class`) for scheduling this system job."
  type        = string
}

variable "plugin_id" {
  default     = "nfs.csi.cloudskeleton.eu"
  description = "Cluster-unique CSI plugin ID referenced by Nomad volumes (must be stable across upgrades)."
  type        = string
}

variable "plugin_version" {
  default     = "1.1.0"
  description = "Container image version tag for the CSI plugin (maps to `registry.gitlab.com/rocketduck/csi-plugin-nfs:v<version>`)."
  type        = string
}
