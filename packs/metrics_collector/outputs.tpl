1. Configure secrets:
```
[[ template "set_parameter_command" (list . "self" "secrets" "system") ]] \
        grafana.admin_user='${GRAFANA_ADMIN_USER}' grafana.admin_password='${GRAFANA_ADMIN_PASSWORD}' \
        influxdb.admin_user='${INFLUXDB_ADMIN_USER}' influxdb.admin_password='${INFLUXDB_ADMIN_PASSWORD}'
```

2. Define the DNS name list for all Nomad cluster nodes in JSON list format:
```
NOMAD_NODES="$({
  nomad server members -json | jq -r '.[].Name | sub("\\.[^.]+$"; "")'
  nomad node status -json | jq -r '.[].Name'
} | jq -Rsc 'split("\n")[:-1]')"
[[ template "set_parameter_command" (list . "self" "config" "system") ]] \
        influxdb.nomad_nodes="${NOMAD_NODES}"
```
