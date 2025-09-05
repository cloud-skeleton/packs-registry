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
                image          = "${DOCKER_IMAGE}"
            }

            driver = "docker"

            env {
                PARAMS_META_PREFIX   = "[[ var "parameters_meta_prefix" . ]]"
                PARAMS_VAR_ROOT_PATH = "[[ var "parameters_root_path" . ]]"
                VOLUMES_META_PREFIX  = "[[ var "volumes_meta_prefix" . ]]"
            }

            resources {
                cpu    = 50
                memory = 32
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "watcher") ]]/images" }}
                DOCKER_IMAGE="ghcr.io/cloud-skeleton/nomad-job-watchdog:{{ index . "ghcr.io/cloud-skeleton/nomad-job-watchdog" }}"
                {{- end }}
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
        [[- template "extra_pack_meta" (list . "https://cloudskeleton.eu/packs-registry/tree/main/packs/job_watchdog") ]]

        // Docker images used in job
        "params.images.ghcr.io/cloud-skeleton/nomad-job-watchdog" = "v1.1"

        // Dynamic configuration
        // "params.config.admin_ip_cidrs" = "[]"
        // "params.config.log_level"      = "INFO"
        // "params.config.ssllabs_cidr"   = "69.67.183.0/24"
    }
    namespace = "system"

    update {
        auto_revert = true
    }
}
