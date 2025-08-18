job "[[ meta "pack.name" . ]]-traefik" {
    namespace = "system"
    type      = "system"

    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "ingress-worker"
    }

    group "traefik" {
        task "plugin" {
            driver = "docker"

            config {
                // args = [
                //     "--node-id=${attr.unique.hostname}",
                //     "--type=monolith",
                //     "--log-level=[[ var "log_level" . ]]",
                //     "--nfs-server=[[ var "nfs_share" . ]]",
                //     "--mount-options=vers=4,lookupcache=positive",
                //     "--allow-nested-volumes"
                // ]
                // cpu_hard_limit = true
                // image          = "registry.gitlab.com/rocketduck/csi-plugin-nfs:[[ var "plugin_version" . ]]"
            }

            resources {
                cpu    = 50
                memory = 32
            }
        }
    }
}
