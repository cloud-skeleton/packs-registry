job "[[ template "job_name" (list . "watcher") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "main-worker"
    }

    group "cloud-skeleton/nomad-job-watchdog" {
        task "service" {
            config {
                cpu_hard_limit = true
                image          = "ghcr.io/cloud-skeleton/nomad-job-watchdog:v[[ var "watchdog_version" . ]]"
            }

            driver = "docker"

            env {
                DEFAULTS_META_PREFIX = "[[ var "defaults_meta_prefix" . ]]"
                PARAMS_VAR_ROOT_PATH = "[[ var "parameters_root_path" . ]]"
            }

            resources {
                cpu    = 50
                memory = 32
            }

            template {
                data = <<-EOF
                {{- with nomadVar "system/tools/nomad-job-watchdog/secrets" }}
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

    meta = {
        "pack.src" = "https://cloudskeleton.eu/packs-registry/tree/main/packs/job_watchdog"
    }
    namespace = "system"
}
