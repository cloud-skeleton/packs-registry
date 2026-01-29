job "[[ template "job_name" (list . "ingester") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "main-worker"
    }

    group "main" {
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
                    grace = "10m"
                    limit = 3
                }

                interval = "30s"
                path     = "/api/health"
                port     = 3000
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

        task "grafana-autoconfig" {
            config {
                args = [
                    "/local/autoconfig_grafana.sh"
                ]
                command        = "bash"
                cpu_hard_limit = true
                entrypoint     = []
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
                memory = 64
            }

            template {
                data        = <<-EOF
[[ fileContents "files/autoconfig_grafana.sh" | indent 16 ]]
                EOF
                destination = "local/autoconfig_grafana.sh"
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="grafana/grafana:{{ index . "grafana/grafana" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/secrets" }}
                GRAFANA_USER="{{ index . "grafana.admin_user" }}"
                GRAFANA_PASSWORD="{{ index . "grafana.admin_password" }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            user = "root"

            volume_mount {
                destination = "/var/lib/grafana"
                volume      = "ui_data"
            }
        }

        task "grafana" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"
            }

            driver = "docker"

            env {
                GF_PATHS_CONFIG = "/local/grafana.ini"
            }

            resources {
                cpu    = 400
                memory = 192
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="grafana/grafana:{{ index . "grafana/grafana" }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/config" }}
                [feature_toggles]
                enable = newInfluxDSConfigPageDesign

                [log]
                level = {{ index . "grafana.log_level" }}
                mode = console
                {{- end }}
                EOF
                destination = "local/grafana.ini"
            }

            user = "root"

            volume_mount {
                destination = "/var/lib/grafana"
                volume      = "ui_data"
            }
        }

        task "influxdb-autoconfig" {
            config {
                args = [
                    "/local/autoconfig_influxdb.sh"
                ]
                command        = "bash"
                cpu_hard_limit = true
                entrypoint     = []
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
[[ fileContents "files/autoconfig_influxdb.sh" | indent 16 ]]
                EOF
                destination = "local/autoconfig_influxdb.sh"
            }

            template {
                data        = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/images" }}
                DOCKER_IMAGE="influxdb:{{ index . "influxdb" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/secrets" }}
                INFLUX_USER="{{ index . "influxdb.admin_user" }}"
                INFLUX_PASSWORD="{{ index . "influxdb.admin_password" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/config" }}
                INFLUX_ORGANIZATION="{{ index . "influxdb.organization_name" }}"
                INFLUX_DATA_RETENTION="{{ index . "influxdb.data_retention" }}"
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }
        }

        task "influxdb" {
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

            kill_signal = "SIGINT"

            resources {
                cpu    = 200
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
                log-level: {{ index . "influxdb.log_level" }}
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
                ui-disabled: true
                ...
                {{- end }}
                EOF
                destination = "local/config.yml"
                uid         = 1000
                gid         = 1000
            }

            volume_mount {
                destination = "/var/lib/influxdb2"
                volume      = "db_data"
            }
        }

        task "telegraf" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"

                mount {
                    readonly = true
                    source   = "local/telegraf.conf"
                    target   = "/etc/telegraf/telegraf.conf"
                    type     = "bind"
                }

                mount {
                    readonly = true
                    source   = "/etc/nomad.d/certs/nomad-agent-ca.pem"
                    target   = "/run/secrets/nomad-agent-ca.pem"
                    type     = "bind"
                }
            }

            driver = "docker"

            lifecycle {
                hook    = "poststart"
                sidecar = true
            }

            resources {
                cpu    = 75
                memory = 96
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
                    debug = true
                    omit_hostname = true
                    skip_processors_after_aggregators = true

                {{- range $nomad_node := (index . "influxdb.nomad_nodes").Value | parseJSON }}
                [[ "[[" ]]inputs.nomad[[ "]]" ]]
                    url = "https://{{ $nomad_node }}:4646"
                    tls_ca = "/run/secrets/nomad-agent-ca.pem"
                    [inputs.nomad.tags]
                        app_name = "nomad"
                {{- end }}

                [[ "[[" ]]outputs.influxdb_v2[[ "]]" ]]
                    bucket_tag = "app_name"
                    exclude_bucket_tag = true
                    organization = "{{ index . "influxdb.organization_name" }}"
                    urls = ["http://127.0.0.1:8086"]
                    {{- with nomadVar "params/[[ template "job_name" (list . "ingester") ]]/state" }}
                    token = "{{ index . "influxdb.telegraf_token" }}"
                    {{- end }}
                {{- end }}
                EOF
                destination = "local/telegraf.conf"
                uid         = 100
                gid         = 101
            }
        }

        [[ template "tunnel_mtls" (list . "ingester" (dict "http" 3000)) ]]

        volume "db_data" {
            access_mode     = "multi-node-multi-writer"
            attachment_mode = "file-system"
            read_only       = false
            source          = "[[ var "db_data_volume.id" . ]]"
            type            = "csi"
        }

        volume "ui_data" {
            access_mode     = "multi-node-multi-writer"
            attachment_mode = "file-system"
            read_only       = false
            source          = "[[ var "ui_data_volume.id" . ]]"
            type            = "csi"
        }
    }

    meta = {
        [[- template "extra_pack_meta" . ]]

        // Dynamic configuration
        "params.config.grafana.log_level"          = "info"
        "params.config.influxdb.data_retention"    = "7d"
        "params.config.influxdb.log_level"         = "info"
        "params.config.influxdb.nomad_nodes"       = "[]"
        "params.config.influxdb.organization_name" = "cloud-skeleton"

        // Docker images used in job
        "params.images.cleanstart/stunnel" = "5.76"
        "params.images.grafana/grafana"    = "12.3.1"
        "params.images.influxdb"           = "2.8-alpine"
        "params.images.telegraf"           = "1.37-alpine"

        // Volumes
        "volumes.[[ var "db_data_volume.id" . ]].id"        = "[[ var "db_data_volume.id" . ]]"
        "volumes.[[ var "db_data_volume.id" . ]].name"      = "[[ var "db_data_volume.name" . ]]"
        "volumes.[[ var "db_data_volume.id" . ]].plugin_id" = "[[ var "db_data_volume.plugin_id" . ]]"
        "volumes.[[ var "ui_data_volume.id" . ]].id"        = "[[ var "ui_data_volume.id" . ]]"
        "volumes.[[ var "ui_data_volume.id" . ]].name"      = "[[ var "ui_data_volume.name" . ]]"
        "volumes.[[ var "ui_data_volume.id" . ]].plugin_id" = "[[ var "ui_data_volume.plugin_id" . ]]"
    }

    namespace = "system"

    update {
        auto_revert       = true
        healthy_deadline  = "14m"
        min_healthy_time  = "2m"
        progress_deadline = "16m"
    }
}
