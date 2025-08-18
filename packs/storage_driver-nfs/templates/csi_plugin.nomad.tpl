job "[[ meta "pack.name" . ]]-csi_plugin-[[ var "id" . ]]" {
    namespace = "system"
    type      = "system"

    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "main-worker"
    }

    group "rocketduck/csi-plugin-nfs" {
        task "plugin" {
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
                image          = "registry.gitlab.com/rocketduck/csi-plugin-nfs:[[ var "plugin_version" . ]]"
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
                memory = 32
            }
        }
    }
}
