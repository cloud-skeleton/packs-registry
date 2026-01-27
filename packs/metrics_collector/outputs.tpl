1. Configure InfluxDB secrets:
[[ template "set_parameter_command" (list . "ingester" "secrets" "system") ]] \
    influxdb.admin_user='${ADMIN_USER}' \
    influxdb.admin_password='${ADMIN_PASSWORD}'

2. Define the DNS name list for all Nomad cluster nodes in JSON list format:
[[ template "set_parameter_command" (list . "ingester" "config" "system") ]] \
    influxdb.nomad_nodes='["${NOMAD_MANAGER}", "${NOMAD_MAIN_WORKER}", "${NOMAD_INGRESS_WORKER}"]'
