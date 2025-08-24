job "[[ template "job_name" (list . "watcher") ]]" {
    group "cloud-skeleton/nomad-job-var-autoacl" {
        task "poststop" {
            config {
                args = [
                    "unlock"
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

            lifecycle {
                hook = "poststop"
            }

            resources {
                cpu    = 500
                memory = 128
            }
        }

        task "prestart" {
            config {
                args = [
                    "lock"
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

            lifecycle {
                hook = "prestart"
                sidecar = false
            }

            resources {
                cpu    = 500
                memory = 128
            }
        }

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
