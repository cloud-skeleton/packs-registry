variable "hostname" {
  description = "The hostname (FQDN) used to access the Grafana monitoring UI."
  type        = string
}

variable "id" {
  description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
  type        = string
}

variable "volumes" {
  description = "CSI volume configuration for persistent data."
  type        = object({
    db_data = object({
      id        = string
      name      = string
      plugin_id = string
    })
    ui_data = object({
      id        = string
      name      = string
      plugin_id = string
    })
  })
}