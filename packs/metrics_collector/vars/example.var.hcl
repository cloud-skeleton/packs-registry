# CSI volume configuration for persistent InfluxDB data (ingester files, WAL, indexes).
data_volume = {
    id        = "metrics_collector-data"
    name      = "metrics_collector/data"
    plugin_id = "nas"
}

// # The hostname (FQDN) used to access the Traefik dashboard. This is the domain that Traefik will serve its web UI on.
// hostname = "lb.cluster.domain.com"

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"