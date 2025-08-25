job "[[ template "job_name" (list . "watcher") ]]" {
    group "cloud-skeleton/nomad-job-watchdog" {
        task "service" {
            config {
                cpu_hard_limit = true
                image          = "ghcr.io/cloud-skeleton/nomad-job-watchdog:v[[ var "watchdog_version" . ]]"
            }

            driver = "docker"

            resources {
                cpu    = 50
                memory = 32
            }

            template {
                data = <<-EOF
                {{- with nomadVar "system/tools/nomad-job-watchdog/token" }}
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

    meta {
        "params.test/test.a" = "a"
        "params.test/test.b" = "a"
    }

    namespace = "system"
}
