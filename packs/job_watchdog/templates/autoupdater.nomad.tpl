job "[[ template "job_name" (list . "autoupdater") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "main-worker"
    }

    group "cloud-skeleton/nomad-job-watchdog-autoupdater" {
        task "task" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
                force_pull     = true
            }

            driver = "docker"

            identity {
                env         = true
                change_mode = "restart"
            }

            resources {
                cpu    = 50
                memory = 32
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "autoupdater") ]]/images" }}
                DOCKER_IMAGE="ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater:{{ index . "ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "autoupdater") ]]/config" }}
                IMAGES_VARIABLE_NAME = "{{ .images_variable_name }}"
                PARAMS_VAR_ROOT_PATH = "{{ .parameters_root_path }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }
        }
    }

    meta = {
        [[- template "extra_pack_meta" . ]]

        // Docker images used in job
        "params.images.ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater" = "v1.0"

        // Dynamic configuration
        "params.config.images_variable_name" = "images"
        "params.config.parameters_root_path" = "params"
    }

    periodic {
        crons            = ["@daily"]
        prohibit_overlap = true
    }

    namespace = "system"
    type      = "batch"
}