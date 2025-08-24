job "[[ template "job_name" (list . "watcher") ]]" {
    group "cloud-skeleton/nomad-job-var-autoacl" {
        task "service" {
            config {
                args = [
                    "start"
                ]
                cpu_hard_limit = true
                image          = "ghcr.io/cloud-skeleton/nomad-job-var-autoacl:v[[ var "autoacl_version" . ]]"
            }

            driver = "docker"

            env {
                NOMAD_UNIX_ADDR = "${NOMAD_SECRETS_DIR}/api.sock"
            }

            resources {
                cpu    = 500
                memory = 128
            }

            template {
                data = <<-EOF
                {{- with nomadVar "system/tools/nomad-job-var-autoacl/token" }}
                {{- range $name, $value := . }}
                {{ $name }}={{ $value }}
                {{- end }}
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }
        }
    }

    namespace = "system"
}
