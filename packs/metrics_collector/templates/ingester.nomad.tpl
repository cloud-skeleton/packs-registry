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
                to = 443
            }
        }

        restart {
            attempts         = 2
            interval         = "2m"
            mode             = "delay"
            render_templates = true
        }

        service {
            // check {
            //     check_restart {
            //         grace = "2m"
            //         limit = 3
            //     }

            //     interval = "30s"
            //     path     = "/health"
            //     port     = "http"
            //     timeout  = "5s"
            //     type     = "http"
            // }

            name     = "[[ template "service_name" (list . "ingester" "http") ]]"
            port     = "http"
            provider = "nomad"
            tags = [
                "traefik.enable=true",
                "traefik.hostname=[[ var "hostname" . ]]",
                "traefik.http.services.[[ template "service_name" (list . "ingester" "http") ]].loadbalancer.serversTransport=mtls@file",
                "traefik.http.services.[[ template "service_name" (list . "ingester" "http") ]].loadbalancer.server.scheme=https"
            ]
            task = "tunnel"
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
                            -t '${INFLUX_TOKEN}' \
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
        }

        task "service" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"

                mount {
                    readonly = true
                    source   = "local/config.yml"
                    target   = "/etc/influxdb2/configs/config.yml"
                    type     = "bind"
                }
            }

            driver = "docker"

            env {
                INFLUXD_CONFIG_PATH = "/etc/influxdb2/configs"
            }

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

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/config" }}
                ---
                bolt-path: /var/lib/influxdb2/influxd.bolt
                engine-path: /var/lib/influxdb2/engine
                hardening-enabled: true
                instance-id: "{{ env "NOMAD_ALLOC_ADDR_http" }}"
                log-level: {{ index . "log_level" }}
                metrics-disabled: true
                pprof-disabled: true
                query-concurrency: 2
                query-initial-memory-bytes: 8388608
                query-memory-bytes: 16777216
                query-queue-size: 12
                reporting-disabled: true
                storage-cache-max-memory-size: 16777216
                storage-cache-snapshot-memory-size: 8388608
                storage-compact-throughput-burst: 8388608
                storage-max-concurrent-compactions: 1
                storage-retention-check-interval: 60m0s
                storage-shard-precreator-check-interval: 30m0s
                strong-passwords: true
                ...
                {{- end }}
                EOF
                destination = "local/config.yml"
                uid         = 1000
                gid         = 1000
            }

            volume_mount {
                destination = "/var/lib/influxdb2"
                volume      = "data"
            }
        }

        task "tunnel" {
            config {
                args           = ["/etc/stunnel/stunnel.conf"]
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"

                mount {
                    readonly = true
                    source   = "local/stunnel.conf"
                    target   = "/etc/stunnel/stunnel.conf"
                    type     = "bind"
                }

                mount {
                    readonly = true
                    source   = "secrets/ca.cert"
                    target   = "/run/secrets/ca.cert"
                    type     = "bind"
                }

                mount {
                    readonly = true
                    source   = "secrets/main.cert"
                    target   = "/run/secrets/main.cert"
                    type     = "bind"
                }

                mount {
                    readonly = true
                    source   = "secrets/main.key"
                    target   = "/run/secrets/main.key"
                    type     = "bind"
                }

                ports = [
                    "http"
                ]
            }

            driver = "docker"

            lifecycle {
                hook    = "prestart"
                sidecar = true
            }

            resources {
                cpu    = 75
                memory = 32
            }

            template {
                data = <<-EOF
                debug = info
                foreground = yes

                [http]
                accept = 0.0.0.0:{{ env "NOMAD_PORT_http" }}
                CAfile = /run/secrets/ca.cert
                cert = /run/secrets/main.cert
                connect = 127.0.0.1:8086
                key = /run/secrets/main.key
                TIMEOUTclose = 3
                TIMEOUTidle = 30
                verify = 2
                EOF
                destination = "local/stunnel.conf"
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="cleanstart/stunnel:{{ index . "cleanstart/stunnel" }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            template {
                data = <<-EOF
                {{ with nomadVar "certs/ingress_to_main/ca" }}
                {{ .certificate }}
                {{ end }}
                EOF
                destination = "secrets/ca.cert"
            }

            template {
                data = <<-EOF
                {{ with nomadVar "certs/ingress_to_main/main" }}
                {{ .certificate }}
                {{ end }}
                EOF
                destination = "secrets/main.cert"
            }

            template {
                data = <<-EOF
                {{ with nomadVar "certs/ingress_to_main/main" }}
                {{ .private_key }}
                {{ end }}
                EOF
                destination = "secrets/main.key"
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
        "params.config.data_retention"    = "30d"
        "params.config.log_level"         = "info"
        "params.config.organization_name" = "cloud-skeleton"

        // Docker images used in job
        "params.images.influxdb"            = "2.7.12-alpine"
        "params.images.cleanstart/stunnel"  = "5.75"

        // Volumes
        "volumes.[[ var "data_volume.id" . ]].id"        = "[[ var "data_volume.id" . ]]"
        "volumes.[[ var "data_volume.id" . ]].name"      = "[[ var "data_volume.name" . ]]"
        "volumes.[[ var "data_volume.id" . ]].plugin_id" = "[[ var "data_volume.plugin_id" . ]]"
    }

    namespace = "system"

    update {
        // auto_promote     = true
        auto_revert       = true
        healthy_deadline  = "2m"
        progress_deadline = "3m"
        // canary           = 1
        // min_healthy_time = "1m"
    }
}
