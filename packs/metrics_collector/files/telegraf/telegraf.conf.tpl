{{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/config" }}
[agent]
  debug = true
  omit_hostname = true
  skip_processors_after_aggregators = true

{{ range $nomad_node := (index . "influxdb.nomad_nodes").Value | parseJSON -}}
[[ "[[" ]]inputs.nomad[[ "]]" ]]
  url = "https://{{ $nomad_node }}:4646"
  tls_ca = "/run/secrets/nomad-agent-ca.pem"
  [inputs.nomad.tags]
    app_name = "nomad"

{{ end -}}

[[ "[[" ]]outputs.influxdb_v2[[ "]]" ]]
  bucket_tag = "app_name"
  exclude_bucket_tag = true
  organization = "{{ index . "influxdb.organization_name" }}"
  urls = [
    {{- range nomadService "[[ template "service_name" (list . "self" "influxdb") ]]" -}}
    "http://{{ .Address }}:{{ .Port }}"
    {{- end -}}
  ]
  {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/state" }}
  token = "{{ index . "influxdb.telegraf_token" }}"
  {{- end }}
{{- end }}