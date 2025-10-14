app {
    url = "https://www.cloudskeleton.eu/packs-registry/tree/main/packs/metrics_collector"
}

pack {
    name        = "metrics_collector"
    description = "Deploys InfluxDB with a Telegraf-powered ingest gateway. Accepts OpenTelemetry (traces, metrics, logs) over gRPC and forwards them to InfluxDB, providing a single endpoint for other jobs."
    version     = "25.10.14"
}
