# CSI volume configuration for persistent InfluxDB data (ingester files, WAL, indexes).
db_data_volume = {
    id        = "metrics_collector-db_data"
    name      = "metrics_collector/db_data"
    plugin_id = "main"
}

# The hostname (FQDN) used to access the InfluxDB 2 web UI and API. This is the domain where InfluxDB will be served.
hostname = "metrics.cluster.domain.com"

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"

# CSI volume configuration for persistent Grafana data.
ui_data_volume = {
    id        = "metrics_collector-ui_data"
    name      = "metrics_collector/ui_data"
    plugin_id = "main"
}