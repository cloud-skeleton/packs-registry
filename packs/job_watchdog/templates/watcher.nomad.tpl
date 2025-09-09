job "[[ template "job_name" (list . "watcher") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "main-worker"
    }

    group "cloud-skeleton/nomad-job-watchdog" {
        restart {
            interval         = "5m"
            mode             = "delay"
            render_templates = true
        }

        task "service" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
            }

            driver = "docker"

            resources {
                cpu    = 50
                memory = 32
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "watcher") ]]/images" }}
                DOCKER_IMAGE="ghcr.io/cloud-skeleton/nomad-job-watchdog:{{ index . "ghcr.io/cloud-skeleton/nomad-job-watchdog" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "watcher") ]]/secrets" }}
                NOMAD_TOKEN="{{ .nomad_token }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "watcher") ]]/config" }}
                PARAMS_META_PREFIX = "{{ .parameters_meta_prefix }}"
                PARAMS_VAR_ROOT_PATH = "{{ .parameters_root_path }}"
                VOLUMES_META_PREFIX = "{{ .volumes_meta_prefix }}"
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
        "params.images.ghcr.io/cloud-skeleton/nomad-job-watchdog" = "v1.2"

        // Dynamic configuration
        "params.config.parameters_meta_prefix" = "params"
        "params.config.parameters_root_path"   = "params"
        "params.config.volumes_meta_prefix"    = "volumes"

        // State
        "params.state.last_event" = "0"
    }
    namespace = "system"

    update {
        auto_revert = true
    }
}
