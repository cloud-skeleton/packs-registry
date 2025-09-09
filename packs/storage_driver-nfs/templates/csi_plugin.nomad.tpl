job "[[ template "job_name" (list . "csi_plugin") ]]" {
    group "rocketduck/csi-plugin-nfs" {
        restart {
            attempts         = 2
            interval         = "2m"
            mode             = "delay"
            render_templates = true
        }

        task "plugin" {
            config {
                args = [
                    "--node-id=${attr.unique.hostname}",
                    "--type=monolith",
                    "--log-level=${LOG_LEVEL}",
                    "--nfs-server=${NFS_SHARE}",
                    "--mount-options=vers=4,lookupcache=positive",
                    "--allow-nested-volumes"
                ]
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
                network_mode   = "host"
                privileged     = true
            }

            csi_plugin {
                health_timeout = "2m"
                id             = "[[ var "id" . ]]"
                type           = "monolith"
            }

            driver = "docker"

            resources {
                cpu    = 50
                memory = 64
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "csi_plugin") ]]/images" }}
                DOCKER_IMAGE="registry.gitlab.com/rocketduck/csi-plugin-nfs:{{ index . "registry.gitlab.com/rocketduck/csi-plugin-nfs" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "csi_plugin") ]]/secrets" }}
                NFS_SHARE="{{ .nfs_share }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "csi_plugin") ]]/config" }}
                LOG_LEVEL="{{ .log_level }}"
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
        "params.images.registry.gitlab.com/rocketduck/csi-plugin-nfs" = "1.1.0"

        // Dynamic configuration
        "params.config.log_level" = "INFO"
    }
    namespace = "system"
    type      = "system"

    update {
        auto_revert = true
    }
}
