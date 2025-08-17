variable "log_level" {
  type = string
  default = "INFO"
  description = "Log verbosity for the CSI plugin process (e.g., TRACE, DEBUG, INFO, WARN, ERROR)."
}

variable "nfs_share" {
  type = string
  description = "NFS server (hostname/IP) or export to use as the backing store, e.g., nas.lan:/export/nomad."
}

variable "node_class" {
  type = string
  default = "main-worker"
  description = "Nomad node class to target (matches node attribute `node.class`) for scheduling this system job."
}

variable "plugin_id" {
  type = string
  default = "nfs.csi.cloudskeleton.eu"
  description = "Cluster-unique CSI plugin ID referenced by Nomad volumes (must be stable across upgrades)."
}

variable "plugin_version" {
  type = string
  default = "1.1.0"
  description = "Container image version tag for the CSI plugin (maps to `registry.gitlab.com/rocketduck/csi-plugin-nfs:v<version>`)."
}
