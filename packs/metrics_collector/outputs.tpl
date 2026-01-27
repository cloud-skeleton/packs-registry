1. Configure secrets:
```
[[ template "set_parameter_command" (list . "ingester" "secrets" "system") ]] \
        grafana.admin_user='${GRAFANA_ADMIN_USER}' grafana.admin_password='${GRAFANA_ADMIN_PASSWORD}' \
        influxdb.admin_user='${INFLUXDB_ADMIN_USER}' influxdb.admin_password='${INFLUXDB_ADMIN_PASSWORD}'
```

2. Define the DNS name list for all Nomad cluster nodes in JSON list format:
```
[[ template "set_parameter_command" (list . "ingester" "config" "system") ]] \
        influxdb.nomad_nodes='["${NOMAD_MANAGER}", "${NOMAD_MAIN_WORKER}", "${NOMAD_INGRESS_WORKER}"]'
```
