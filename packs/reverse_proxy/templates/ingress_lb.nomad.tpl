job "[[ meta "pack.name" . ]]-ingress_load_balancer-[[ var "id" . ]]" {
    namespace = "system"
    type      = "system"

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
        }

        volume "certificates" {
            type            = "csi"
            source          = "[[ var "certificates_volume" . ]]"
            read_only       = false
            access_mode     = "multi-node-multi-writer"
            attachment_mode = "file-system"
        }
    }
}
