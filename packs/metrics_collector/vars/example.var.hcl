# The hostname (FQDN) used to access the Grafana monitoring UI.
hostname = "metrics.cluster.domain.com"

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"

# CSI volume configuration for persistent data.
volumes = {
  db_data = {
    id        = "metrics_collector-db_data"
    name      = "metrics_collector/db_data"
    plugin_id = "main"
  }

  ui_data = {
    id        = "metrics_collector-ui_data"
    name      = "metrics_collector/ui_data"
    plugin_id = "main"
  }
}