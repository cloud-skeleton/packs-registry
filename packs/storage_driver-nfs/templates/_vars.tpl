[[- define "extra_pack_meta" -]]
[[- $max_var_name_length := 0 -]]
[[- range $name, $_ := vars . -]]
[[- $max_var_name_length = max $max_var_name_length (len $name) -]]
[[- end ]]
    // Nomad pack source URL
    [[ printf "\"pack.src\" = \"%v\"" (meta "app.url" .) ]]

    // Nomad pack variables used during deployment
    [[- range $name, $value := vars . ]]
    [[ printf "\"pack.vars.%s\"%*s= \"%v\"" $name (add 1 (sub $max_var_name_length (len $name))) "" $value -]]
    [[- end ]]
[[- end -]]

[[- define "job_name" -]]
[[- $root := index . 0 -]]
[[- $name := index . 1 -]]
[[ printf "%s-%s-%s" (meta "pack.name" $root) $name (var "id" $root) ]]
[[- end -]]

[[- define "job_policy_description" -]]
[[- $root := index . 0 -]]
[[- $name := index . 1 -]]
[[ printf "JOB POLICY: Allow extra permissions for %s-%s-%s job" (meta "pack.name" $root) $name (var "id" $root) ]]
[[- end -]]

[[- define "job_policy_name" -]]
[[- $root := index . 0 -]]
[[- $name := index . 1 -]]
[[ printf "JOB-POLICY-%s-%s-%s" (meta "pack.name" $root) $name (var "id" $root) | replace "_" "-" ]]
[[- end -]]

[[- define "service_name" -]]
[[- $root := index . 0 -]]
[[- $name := index . 1 -]]
[[- $suffix := index . 2 -]]
[[- if $suffix -]]
[[- $suffix = printf "-%s" $suffix -]]
[[- end -]]
[[ printf "%s-%s%s-%s" (meta "pack.name" $root) $name $suffix (var "id" $root) | replace "_" "-" | trunc 63 ]]
[[- end -]]

[[- define "tunnel_mtls" -]]
[[- $root := index . 0 -]]
[[- $job_name := index . 1 -]]
[[- $ports := index . 2 -]]
    task "tunnel" {
      config {
        args = [
          "/local/stunnel.conf"
        ]
        cpu_hard_limit = true
        image          = "${DOCKER_IMAGE}"
        ports = [
          [[- range $name, $port := $ports ]]
          "[[ $name ]]",
          [[- end ]]
        ]
      }

      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      resources {
        cpu    = 200
        memory = 48
      }

      template {
        data = <<-EOF
        debug = notice
        foreground = yes
        [[- range $name, $port := $ports ]]

        [[ printf "[%s]" $name ]]
        accept = 0.0.0.0:{{ env "NOMAD_PORT_[[ $name ]]" }}
        CAfile = /secrets/ca.cert
        cert = /secrets/main.cert
        connect = 127.0.0.1:[[ $port ]]
        key = /secrets/main.key
        TIMEOUTclose = 5
        TIMEOUTidle = 35
        verify = 2
        [[- end ]]
        EOF
        destination = "local/stunnel.conf"
      }

      template {
        data = <<-EOF
        {{- with nomadVar "params/[[ template "job_name" (list $root $job_name) ]]/images" }}
        DOCKER_IMAGE="cleanstart/stunnel:{{ index . "cleanstart/stunnel" }}"
        {{- end }}
        EOF
        destination = "secrets/env"
        env         = true
      }

      [[- range $certificate := list "ca" "main" ]]

      template {
        data = <<-EOF
        {{ with nomadVar "certs/ingress_to_main/[[ $certificate ]]" }}
        {{ .certificate }}
        {{ end }}
        EOF
        destination = "secrets/[[ $certificate ]].cert"
      }
      [[- end ]]

      template {
        data = <<-EOF
        {{ with nomadVar "certs/ingress_to_main/main" }}
        {{ .private_key }}
        {{ end }}
        EOF
        destination = "secrets/main.key"
      }
    }
[[- end -]]

[[- define "set_parameter_command" -]]
[[- $root := index . 0 -]]
[[- $job_name := index . 1 -]]
[[- $parameter_name := index . 2 -]]
[[- $parameter_namespace := "default" -]]
[[- if ge (len .) 4 -]]
  [[- $parameter_namespace = index . 3 -]]
[[- end -]]
[[- $variable := printf "params/%s-%s-%s/%s" (meta "pack.name" $root) $job_name (var "id" $root) $parameter_name -]]
[[ printf "nomad var get -namespace=%s %s \\\n    | nomad var put -force -namespace=%s %s -"
$parameter_namespace $variable $parameter_namespace $variable ]]
[[- end -]]
