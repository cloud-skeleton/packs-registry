---
{{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/state" }}
apiVersion: 1
datasources:
  - access: proxy
    isDefault: true
    jsonData:
      dbName: nomad
      httpMode: POST
      product: InfluxDB OSS 2.x
      version: InfluxQL
    name: influxdb
    secureJsonData:
      password: {{ index . "influxdb.grafana_token" }}
    type: influxdb
    user: grafana
    {{- range nomadService "[[ template "service_name" (list . "self" "influxdb") ]]" }}
    url: http://{{ .Address }}:{{ .Port }}
    {{- end }}
    uid: 0000-0000-0000-0000
{{- end }}
...