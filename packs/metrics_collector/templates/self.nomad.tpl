job "[[ template "job_name" (list . "self") ]]" {
  constraint {
    attribute = "${node.class}"
    operator  = "="
    value     = "main-worker"
  }

  group "grafana" {
    network {
      mode = "bridge"

      port "http" {
        to = 443
      }
    }

    restart {
      attempts         = 2
      interval         = "25m"
      mode             = "delay"
      render_templates = true
    }

    service {
      check {
        address_mode = "alloc"

        check_restart {
          grace = "7m"
          limit = 4
        }

        interval = "15s"
        path     = "/api/health"
        port     = 3000
        timeout  = "5s"
        type     = "http"
      }

      name     = "[[ template "service_name" (list . "self" "http") ]]"
      port     = "http"
      provider = "nomad"
      tags = [
        "traefik.enable=true",
        "traefik.hostname=[[ var "hostname" . ]]",
        "traefik.http.services.[[ template "service_name" (list . "self" "http") ]].loadbalancer.serversTransport=mtls@file",
        "traefik.http.services.[[ template "service_name" (list . "self" "http") ]].loadbalancer.server.scheme=https"
      ]
      task = "tunnel"
    }

    task "grafana" {
      config {
        cpu_hard_limit = true
        image          = "${DOCKER_IMAGE}"
      }

      driver = "docker"

      env {
        GF_PATHS_CONFIG       = "/alloc/grafana.ini"
        GF_PATHS_PROVISIONING = "/local"
        GF_SERVER_DOMAIN      = "[[ var "hostname" . ]]"
        GF_SERVER_ROOT_URL    = "https://[[ var "hostname" . ]]"
      }

      kill_signal = "SIGINT"

      resources {
        cpu    = 400
        memory = 512
      }

      template {
        data = <<-EOF
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/images" }}
        DOCKER_IMAGE="grafana/grafana:{{ index . "grafana/grafana" }}"
        {{- end }}
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/state" }}
        GF_SECURITY_SECRET_KEY="{{ index . "grafana.secret_key" }}"
        {{- end }}
        EOF
        destination = "secrets/env"
        env         = true
      }

      template {
        data        = <<-EOF
[[ fileContents "files/grafana/grafana.ini" | indent 8 ]]
        EOF
        destination = "../alloc/grafana.ini"
      }

      template {
        data        = <<-EOF
[[ fileContents "files/grafana/nomad-dashboard.json" | indent 8 ]]
        EOF
        destination = "local/dashboards/nomad.json"
      }

      template {
        data        = <<-EOF
[[ fileContents "files/grafana/dashboards-provider.yml" | indent 8 ]]
        EOF
        destination = "local/dashboards/dashboards.yml"
      }

      template {
        data        = <<-EOF
[[ tpl (fileContents "files/grafana/influxdb-datasource.yml.tpl") . | indent 8 ]]
        EOF
        destination = "local/datasources/influxdb.yml"
      }

      user = "root"

      volume_mount {
        destination = "/var/lib/grafana"
        volume      = "ui_data"
      }
    }

    task "grafana-postconfig" {
      config {
        args = [
          "/local/postconfig_grafana.sh"
        ]
        command        = "bash"
        cpu_hard_limit = true
        entrypoint     = []
        image          = "${DOCKER_IMAGE}"
      }

      driver = "docker"

      env {
        GF_PATHS_CONFIG       = "/alloc/grafana.ini"
        GF_PATHS_PROVISIONING = "/local"
        GF_SERVER_DOMAIN      = "[[ var "hostname" . ]]"
        GF_SERVER_ROOT_URL    = "https://[[ var "hostname" . ]]"
      }

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
[[ fileContents "files/grafana/postconfig_grafana.sh" | indent 8 ]]
        EOF
        destination = "local/postconfig_grafana.sh"
      }

      template {
        data        = <<-EOF
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/images" }}
        DOCKER_IMAGE="grafana/grafana:{{ index . "grafana/grafana" }}"
        {{- end }}
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/secrets" }}
        GRAFANA_USER="{{ index . "grafana.admin_user" }}"
        GRAFANA_PASSWORD="{{ index . "grafana.admin_password" }}"
        {{- end }}
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/config" }}
        GRAFANA_ORGANIZATION="{{ index . "grafana.organization_name" }}"
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

[[ template "tunnel_mtls" (list . "self" (dict "http" 3000)) ]]

    update {
      healthy_deadline = "24m30s"
    }

    volume "ui_data" {
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
      read_only       = false
      source          = "[[ var "volumes.ui_data.id" . ]]"
      type            = "csi"
    }
  }

  group "influxdb" {
    network {
      mode = "bridge"

      port "influxdb" {
        to = 8086
      }
    }

    restart {
      attempts         = 2
      interval         = "7m"
      mode             = "delay"
      render_templates = true
    }

    service {
      check {
        check_restart {
          grace = "1m"
          limit = 4
        }

        interval = "15s"
        path     = "/health"
        port     = "influxdb"
        timeout  = "5s"
        type     = "http"
      }

      name     = "[[ template "service_name" (list . "self" "influxdb") ]]"
      port     = "influxdb"
      provider = "nomad"
      task     = "influxdb"
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

      shutdown_delay = "5s"

      template {
        data        = <<-EOF
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/images" }}
        DOCKER_IMAGE="influxdb:{{ index . "influxdb" }}"
        {{- end }}
        EOF
        destination = "secrets/env"
        env         = true
      }

      template {
        data        = <<-EOF
[[ fileContents "files/influxdb/influxdb.yml.tpl" | indent 8 ]]
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

    task "influxdb-postconfig" {
      config {
        args = [
          "/local/postconfig_influxdb.sh"
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
[[ fileContents "files/influxdb/postconfig_influxdb.sh" | indent 8 ]]
        EOF
        destination = "local/postconfig_influxdb.sh"
      }

      template {
        data        = <<-EOF
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/images" }}
        DOCKER_IMAGE="influxdb:{{ index . "influxdb" }}"
        {{- end }}
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/secrets" }}
        INFLUX_USER="{{ index . "influxdb.admin_user" }}"
        INFLUX_PASSWORD="{{ index . "influxdb.admin_password" }}"
        {{- end }}
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/config" }}
        INFLUX_ORGANIZATION="{{ index . "influxdb.organization_name" }}"
        INFLUX_DATA_RETENTION="{{ index . "influxdb.data_retention" }}"
        {{- end }}
        EOF
        destination = "secrets/env"
        env         = true
      }
    }

    update {
      healthy_deadline = "6m30s"
    }

    volume "db_data" {
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
      read_only       = false
      source          = "[[ var "volumes.db_data.id" . ]]"
      type            = "csi"
    }
  }

  group "telegraf" {
    network {
      mode = "bridge"
    }

    restart {
      attempts         = 2
      interval         = "13m"
      mode             = "delay"
      render_templates = true
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

      driver       = "docker"
      kill_timeout = "30s"

      resources {
        cpu    = 75
        memory = 96
      }

      template {
        data = <<-EOF
        {{- with nomadVar "params/[[ template "job_name" (list . "self") ]]/images" }}
        DOCKER_IMAGE="telegraf:{{ index . "telegraf" }}"
        {{- end }}
        EOF
        destination = "secrets/env"
        env         = true
      }

      template {
        data        = <<-EOF
[[ tpl (fileContents "files/telegraf/telegraf.conf.tpl") . | indent 8 ]]
        EOF
        destination = "local/telegraf.conf"
        uid         = 100
        gid         = 101
      }
    }

    # Telegraf starts quickly once its configuration is rendered, but on a fresh
    # deployment it depends on InfluxDB post-configuration creating the Telegraf
    # token and storing it in Nomad Variables. These deployment deadlines allow
    # Telegraf to wait for worst-case InfluxDB cold start and initialization.
    update {
      health_check     = "task_states"
      healthy_deadline = "12m30s"
    }
  }

  meta = {
    [[- template "extra_pack_meta" . ]]

    // Dynamic configuration
    "params.config.grafana.organization_name"  = "Cloud Skeleton"
    "params.config.influxdb.data_retention"    = "604800"
    "params.config.influxdb.nomad_nodes"       = "[]"
    "params.config.influxdb.organization_name" = "cloud-skeleton"

    // Docker images used in job
    "params.images.cleanstart/stunnel" = "5.79"
    "params.images.grafana/grafana"    = "13.1.3"
    "params.images.influxdb"           = "2.9.1-alpine"
    "params.images.telegraf"           = "1.39.2-alpine"

    // Volumes
    "volumes.[[ var "volumes.db_data.id" . ]].id"        = "[[ var "volumes.db_data.id" . ]]"
    "volumes.[[ var "volumes.db_data.id" . ]].name"      = "[[ var "volumes.db_data.name" . ]]"
    "volumes.[[ var "volumes.db_data.id" . ]].plugin_id" = "[[ var "volumes.db_data.plugin_id" . ]]"
    "volumes.[[ var "volumes.ui_data.id" . ]].id"        = "[[ var "volumes.ui_data.id" . ]]"
    "volumes.[[ var "volumes.ui_data.id" . ]].name"      = "[[ var "volumes.ui_data.name" . ]]"
    "volumes.[[ var "volumes.ui_data.id" . ]].plugin_id" = "[[ var "volumes.ui_data.plugin_id" . ]]"
  }

  namespace = "system"

  update {
    auto_revert       = true
    min_healthy_time  = "30s"
    progress_deadline = "0"
  }
}
