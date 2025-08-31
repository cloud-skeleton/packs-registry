job "[[ template "job_name" (list . "csi_plugin") ]]" {
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

    meta = {
        [[- template "extra_pack_meta" (list . "https://github.com/cloud-skeleton/packs-registry/tree/main/packs/storage_driver-nfs") ]]
    }
    namespace = "system"
    type      = "system"
}
