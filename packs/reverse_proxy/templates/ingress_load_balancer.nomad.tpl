job "[[ meta "pack.name" . ]]-ingress_load_balancer-[[ var "id" . ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "ingress-worker"
    }

    group "traefik" {
        task "service" {
            config {
                cpu_hard_limit = true
                image          = "traefik:v[[ var "traefik_version" . ]]"
            }

            driver = "docker"

            resources {
                cpu    = 1000
                memory = 64
            }

            volume_mount {
                volume      = "certificates"
                destination = "/certificates"
            }
        }

        volume "certificates" {
            access_mode     = "multi-node-multi-writer"
            attachment_mode = "file-system"
            read_only       = false
            source          = "[[ var "certificates_volume_id" . ]]"
            type            = "csi"
        }
    }

    namespace = "system"
    type      = "system"
}
