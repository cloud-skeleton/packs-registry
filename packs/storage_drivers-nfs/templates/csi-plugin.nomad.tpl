job "csi-plugin" {
    namespace = "[[ namespace ]]"
    type      = "system"

    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "[[ node_class ]]"
    }

    group "rocketduck/csi-plugin-nfs" {
        task "plugin" {
            driver = "docker"

            config {
                args = [
                    "--node-id=${attr.unique.hostname}",
                    "--type=monolith",
                    "--log-level=[[ log_level ]]",
                    "--nfs-server=[[ nfs_share ]]",
                    "--mount-options=vers=4,lookupcache=positive",
                    "--allow-nested-volumes"
                ]
                cpu_hard_limit = true
                image          = "registry.gitlab.com/rocketduck/csi-plugin-nfs:v[[ plugin_version ]]"
                network_mode   = "host"
                privileged     = true
            }

            csi_plugin {
                health_timeout = "2m"
                id             = "[[ plugin_id ]]"
                type           = "monolith"
            }

            resources {
                cpu    = 50
                memory = 32
            }
        }
    }
}
