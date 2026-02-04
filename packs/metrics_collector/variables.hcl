variable "db_data_volume" {
  description = "CSI volume configuration for persistent InfluxDB data (ingester files, WAL, indexes)."
  type        = object({
    id        = string
    name      = string
    plugin_id = string
  })
}

variable "hostname" {
  description = "The hostname (FQDN) used to access the InfluxDB 2 web UI and API. This is the domain where InfluxDB will be served."
  type        = string
}

variable "id" {
  description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
  type        = string
}

variable "ui_data_volume" {
  description = "CSI volume configuration for persistent Grafana data."
  type        = object({
    id        = string
    name      = string
    plugin_id = string
  })
}