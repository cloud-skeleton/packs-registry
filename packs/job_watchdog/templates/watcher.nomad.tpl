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
        // Backup pack variables values
        [[- range $name, $value := vars . ]]
        "params.nomad_pack.backup_variables.[[ $name ]]" = "[[ printf "%v" $value ]]"
        [[- end ]]
        // "params.backup_variables.id"                     = "[[ var "id" . ]]"
        // "params.backup_variables.parameters_meta_prefix" = "[[ var "parameters_meta_prefix" . ]]"
        // "params.backup_variables.parameters_root_path"   = "[[ var "parameters_root_path" . ]]"
        // "params.backup_variables.volumes_meta_prefix"    = "[[ var "volumes_meta_prefix" . ]]"
        // "params.backup_variables.watchdog_version"       = "[[ var "watchdog_version" . ]]"
        // Set additional pack source URL
        "pack.src"                             = "https://cloudskeleton.eu/packs-registry/tree/main/packs/job_watchdog"
    }
    namespace = "system"
}
