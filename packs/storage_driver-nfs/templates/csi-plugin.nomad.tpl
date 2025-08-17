job "[[ meta "pack.name" . ]]-csi_plugin" {
    namespace = "[[ var "namespace" . ]]"
    type      = "system"

    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "[[ var "node_class" . ]]"
    }

    group "rocketduck/csi-plugin-nfs" {
        task "plugin" {
            driver = "docker"

            config {
                args = [
                    "--node-id=${attr.unique.hostname}",
                    "--type=monolith",
                    "--log-level=[[ var "log_level" . ]]",
                    "--nfs-server=[[ var "nfs_share" . ]]",
                    "--mount-options=vers=4,lookupcache=positive",
                    "--allow-nested-volumes"
                ]
                cpu_hard_limit = true
                image          = "registry.gitlab.com/rocketduck/csi-plugin-nfs:v[[ var "plugin_version" . ]]"
                network_mode   = "host"
                privileged     = true
            }

            csi_plugin {
                health_timeout = "2m"
                id             = "[[ var "plugin_id" . ]]"
                type           = "monolith"
            }

            resources {
                cpu    = 50
                memory = 32
            }
        }
    }
}
