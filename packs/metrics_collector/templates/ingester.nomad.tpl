job "[[ template "job_name" (list . "ingester") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "main-worker"
    }

    group "influxdb" {
        network {
            mode = "bridge"

            port "http" {
                to = 8086
            }
        }

        restart {
            attempts         = 2
            interval         = "2m"
            mode             = "delay"
            render_templates = true
        }

        service {
            check {
                check_restart {
                    grace = "2m"
                    limit = 3
                }

                interval = "30s"
                path     = "/health"
                port     = "http"
                timeout  = "5s"
                type     = "http"
            }

            name     = "[[ template "service_name" (list . "ingester" "http") ]]"
            port     = "http"
            provider = "nomad"
            tags = [
                "traefik.hostname=[[ var "hostname" . ]]"
            ]
            task = "service"
        }

        task "setup" {
            config {
                args = [
                    "-c",
                    <<-EOS
                    while ! influx ping 2> /dev/null; do
                        sleep 5
                    done
                    if ! influx org ls -n '${INFLUX_ORGANIZATION}' 2> /dev/null; then
                        influx setup \
                            -u '${INFLUX_USER}' \
                            -p '${INFLUX_PASSWORD}' \
                            -o '${INFLUX_ORGANIZATION}' \
                            -b '${INFLUX_BUCKET}' \
                            -r '${INFLUX_DATA_RETENTION}' -f
                    fi
                    EOS
                ]
                command        = "sh"
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
            }

            driver = "docker"

            lifecycle {
                hook = "poststart"
            }

            resources {
                cpu    = 25
                memory = 16
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="influxdb:{{ index . "influxdb" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/secrets" }}
                INFLUX_TOKEN={{ index . "token" }}
                INFLUX_USER={{ index . "user" }}
                INFLUX_PASSWORD={{ index . "password" }}
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/config" }}
                INFLUX_BUCKET={{ index . "bucket_name" }}
                INFLUX_ORGANIZATION={{ index . "organization_name" }}
                INFLUX_DATA_RETENTION={{ index . "data_retention" }}
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            volume_mount {
                destination = "/var/lib/influxdb2"
                volume      = "data"
            }
        }

        task "service" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
                ports = [
                    "http"
                ]
            }

            driver = "docker"

            resources {
                cpu    = 100
                memory = 128
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="influxdb:{{ index . "influxdb" }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            volume_mount {
                destination = "/var/lib/influxdb2"
                volume      = "data"
            }
        }

        volume "data" {
            access_mode     = "multi-node-multi-writer"
            attachment_mode = "file-system"
            read_only       = false
            source          = "[[ var "data_volume.id" . ]]"
            type            = "csi"
        }
    }

    meta = {
        [[- template "extra_pack_meta" . ]]

        // Dynamic configuration
        "params.config.bucket_name"       = "system"
        "params.config.organization_name" = "cloud-skeleton"
        "params.config.data_retention"    = "30d"

        // Docker images used in job
        "params.images.influxdb" = "2.7.12-alpine"

        // Volumes
        "volumes.[[ var "data_volume.id" . ]].id"        = "[[ var "data_volume.id" . ]]"
        "volumes.[[ var "data_volume.id" . ]].name"      = "[[ var "data_volume.name" . ]]"
        "volumes.[[ var "data_volume.id" . ]].plugin_id" = "[[ var "data_volume.plugin_id" . ]]"
    }

    namespace = "system"

    update {
        // auto_promote     = true
        auto_revert      = true
        // canary           = 1
        // min_healthy_time = "1m"
    }
}
