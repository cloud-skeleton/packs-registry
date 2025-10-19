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
            check {
                address_mode = "alloc"

                check_restart {
                    grace = "3m"
                    limit = 3
                }

                interval = "30s"
                path     = "/health"
                port     = 8086
                timeout  = "2s"
                type     = "http"
            }

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

        task "influxdb-autoconfig" {
            config {
                args = [
                    "local/autoconfig.sh"
                ]
                command        = "bash"
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
            }

            driver = "docker"

            identity {
                change_mode = "restart"
                env         = true
            }

            kill_timeout = "30s"

            lifecycle {
                hook    = "poststart"
                sidecar = true
            }

            resources {
                cpu    = 25
                memory = 16
            }

            template {
                data        = <<-EOF
[[ fileContents "files/autoconfig.sh" | indent 16 ]]
                EOF
                destination = "local/autoconfig.sh"
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="influxdb:{{ index . "influxdb" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/secrets" }}
                INFLUX_USER={{ index . "admin_user" }}
                INFLUX_PASSWORD={{ index . "admin_password" }}
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

        task "influxdb-service" {
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

            kill_signal  = "SIGINT"
            leader       = true

            resources {
                cpu    = 100
                memory = 256
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="influxdb:{{ index . "influxdb" }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            template {
                data        = <<-EOF
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

        task "telegraf-service" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"

                mount {
                    readonly = true
                    source   = "local/telegraf.conf"
                    target   = "/etc/telegraf/telegraf.conf"
                    type     = "bind"
                }
            }

            driver = "docker"

            resources {
                cpu    = 50
                memory = 32
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="telegraf:{{ index . "telegraf" }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/config" }}
                [agent]
                skip_processors_after_aggregators = true

                [[ "[[" ]]inputs.statsd[[ "]]" ]]


                [[ "[[" ]]outputs.influxdb_v2[[ "]]" ]]
                urls = ["http://127.0.0.1:8086"]
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/state" }}
                token = "{{ .telegraf_token }}"
                {{- end }}
                organization = "{{ .organization_name }}"
                bucket = "{{ .bucket_name }}"
                {{- end }}
                EOF
                destination = "local/telegraf.conf"
                uid         = 100
                gid         = 101
            }
        }

        [[ template "tunnel_mtls" (list . "ingester" (dict "http" 8086)) ]]

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
        "params.images.influxdb"           = "2.7.12-alpine"
        "params.images.cleanstart/stunnel" = "5.75"
        "params.images.telegraf"           = "1.36.2-alpine"

        // Volumes
        "volumes.[[ var "data_volume.id" . ]].id"        = "[[ var "data_volume.id" . ]]"
        "volumes.[[ var "data_volume.id" . ]].name"      = "[[ var "data_volume.name" . ]]"
        "volumes.[[ var "data_volume.id" . ]].plugin_id" = "[[ var "data_volume.plugin_id" . ]]"
    }

    namespace = "system"

    update {
        auto_revert       = true
        healthy_deadline  = "2m"
        min_healthy_time  = "30s"
        progress_deadline = "3m"
    }
}
