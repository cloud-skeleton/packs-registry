---
bolt-path: /var/lib/influxdb2/influxd.bolt
engine-path: /var/lib/influxdb2/engine
hardening-enabled: true
instance-id: {{ env "NOMAD_ALLOC_ADDR_influxdb" }}
metrics-disabled: true
pprof-disabled: true
query-concurrency: 2
query-initial-memory-bytes: 8388608
query-memory-bytes: 16777216
query-queue-size: 12
reporting-disabled: true
storage-cache-max-memory-size: 16777216
storage-cache-snapshot-memory-size: 8388608
storage-compact-throughput-burst: 8388608
storage-max-concurrent-compactions: 1
storage-retention-check-interval: 60m0s
storage-shard-precreator-check-interval: 30m0s
strong-passwords: true
ui-disabled: true
...