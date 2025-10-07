job "[[ template "job_name" (list . "autoupdater") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "main-worker"
    }

    group "cloud-skeleton/nomad-job-watchdog-autoupdater" {
        restart {
            attempts         = 2
            interval         = "2m"
            mode             = "delay"
            render_templates = true
        }

        task "task" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
            }

            driver = "docker"

            identity {
                change_mode = "restart"
                env         = true
            }

            kill_timeout = "5m"
            kill_signal  = "SIGINT"

            resources {
                cpu    = 50
                memory = 32
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "autoupdater") ]]/images" }}
                DOCKER_IMAGE="ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater:{{ index . "ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "autoupdater") ]]/config" }}
                CERTS_VAR_ROOT_PATH="{{ .certificates_root_path }}"
                IMAGES_VARIABLE_NAME="{{ .images_variable_name }}"
                INGRESS_WORKER_IPS={{ .ingress_worker_ips | toJSON }}
                MAIN_WORKER_IPS={{ .main_worker_ips | toJSON }}
                PARAMS_VAR_ROOT_PATH="{{ .parameters_root_path }}"
                {{- $lock := .version_update_lock.Value | parseJSON }}
                DO_NOT_ALLOW_UPDATE_MAJOR_VERSION="{{ if $lock.major }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_MINOR_VERSION="{{ if $lock.minor }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_PATCH_VERSION="{{ if $lock.patch }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_PRERELEASE_VERSION="{{ if $lock.prerelease }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_BUILD_VERSION="{{ if $lock.build }}true{{ else }}false{{ end }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }
        }
    }

    meta = {
        [[- template "extra_pack_meta" . ]]

        // Dynamic configuration
        "params.config.certificates_root_path" = "certs"
        "params.config.images_variable_name"   = "images"
        "params.config.ingress_worker_ips"     = "[]"
        "params.config.main_worker_ips"        = "[]"
        "params.config.parameters_root_path"   = "params"
        "params.config.version_update_lock"    = "{\"major\": true, \"minor\": false, \"patch\": false, \"prerelease\": true, \"build\": true}"

        // Docker images used in job
        "params.images.ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater" = "v1.2"
    }

    namespace = "system"

    periodic {
        crons            = ["[[ var "autoupdater_cron.cron" . ]]"]
        prohibit_overlap = true
        time_zone        = "[[ var "autoupdater_cron.timezone" . ]]"
    }

    type = "batch"
}
