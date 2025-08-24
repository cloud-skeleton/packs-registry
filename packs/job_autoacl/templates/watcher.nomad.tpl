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

            identity {
                env = true
            }

            resources {
                cpu    = 500
                memory = 128
            }
        }
    }

    namespace = "system"
}
