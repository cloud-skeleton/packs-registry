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
                {{- $lock := .version_update_lock.Value | parseJSON }}
                DO_NOT_ALLOW_UPDATE_MAJOR_VERSION = "{{ if $lock.major }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_MINOR_VERSION = "{{ if $lock.minor }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_PATCH_VERSION = "{{ if $lock.patch }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_PRERELEASE_VERSION = "{{ if $lock.prerelease }}true{{ else }}false{{ end }}"
                DO_NOT_ALLOW_UPDATE_BUILD_VERSION = "{{ if $lock.build }}true{{ else }}false{{ end }}"
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
        "params.config.version_update_lock" = "{\"major\":true,\"minor\":false,\"patch\":false,\"prerelease\":true,\"build\":true}"
    }

    periodic {
        crons            = ["@daily"]
        prohibit_overlap = true
    }

    namespace = "system"
    type      = "batch"
}