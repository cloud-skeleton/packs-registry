job "[[ template "job_name" (list . "ingress_load_balancer") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "ingress-worker"
    }

    group "traefik" {
        network {
            mode = "bridge"

            port "http" {
                static = 80
            }

            port "https" {
                static = 443
            }
        }

        restart {
            attempts         = 2
            interval         = "2m"
            mode             = "delay"
            render_templates = true
        }

        service {
            address = "[[ var "traefik_hostname" . ]]"

            check {
                check_restart {
                    grace = "2m"
                    limit = 3
                }

                interval = "30s"
                path     = "/ping"
                port     = "https"
                protocol = "https"
                timeout  = "5s"
                type     = "http"
            }

            name     = "[[ template "service_name" (list . "ingress_load_balancer") ]]"
            port     = "https"
            provider = "nomad"
            task     = "service"
        }

        task "service" {
            config {
                cpu_hard_limit = true
                image          = "${DOCKER_IMAGE}"

                mount {
                    readonly = true
                    source   = "local/traefik_dynamic.yml"
                    target   = "/etc/traefik/dynamic.yml"
                    type     = "bind"
                }

                mount {
                    readonly = true
                    source   = "local/traefik_static.yml"
                    target   = "/etc/traefik/traefik.yml"
                    type     = "bind"
                }

                ports = [
                    "http",
                    "https"
                ]
            }

            driver = "docker"

            identity {
                change_mode = "restart"
                env         = true
            }

            resources {
                cpu    = 100
                memory = 64
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingress_load_balancer") ]]/images" }}
                DOCKER_IMAGE="traefik:{{ index . "traefik" }}"
                {{- end }}
                {{- with nomadVar "params/[[ template "job_name" (list . "ingress_load_balancer") ]]/dns" }}
                {{- range $name, $value := . }}
                {{ $name }}={{ $value }}
                {{- end }}
                {{- end }}
                EOF
                destination = "secrets/env"
                env         = true
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingress_load_balancer") ]]/config" }}
                ---
                api: {}
                certificatesResolvers:
                    lets-encrypt:
                        acme:
                            dnsChallenge:
                                {{- with nomadVar "params/[[ template "job_name" (list . "ingress_load_balancer") ]]/dns" }}
                                provider: {{ .CODE }}
                                {{- end }}
                            keyType: EC384
                            storage: /certificates/acme.json
                entrypoints:
                    http:
                        address: :{{ env "NOMAD_PORT_http" }}
                        http:
                            encodeQuerySemicolons: true
                            redirections:
                                entryPoint:
                                    permanent: true
                                    to: https
                        http3: {}
                        reusePort: true
                    https:
                        address: :{{ env "NOMAD_PORT_https" }}
                        asDefault: true
                        http:
                            encodeQuerySemicolons: true
                            middlewares:
                                - security-headers@file
                            tls:
                                certResolver: lets-encrypt
                        http3: {}
                        reusePort: true
                experimental:
                    plugins:
                        static-response:
                            moduleName: github.com/tuxgal/traefik_inline_response
                            version: v0.1.2
                global:
                    checkNewVersion: false
                    sendAnonymousUsage: false
                log:
                    level: {{ .log_level }}
                ping:
                    manualRouting: true
                providers:
                    file:
                        filename: /etc/traefik/dynamic.yml
                    nomad:
                        defaultRule: "Host(`{{"{{"}} normalize .Name {{"}}"}}`)"
                        endpoint:
                            address: {{ env "NOMAD_UNIX_ADDR" }}
                        exposedByDefault: false
                        prefix: expose
                        stale: true
                        watch: true
                ...
                {{- end }}
                EOF
                destination = "local/traefik_static.yml"
            }

            template {
                data = <<-EOF
                {{- with nomadVar "params/[[ template "job_name" (list . "ingress_load_balancer") ]]/config" }}
                ---
                http:
                    middlewares:
                        admin-ip-only:
                            IPAllowList:
                                {{- $admin_ip_cidrs := .admin_ip_cidrs.Value | parseJSON }}
                                sourceRange: {{ if eq (len $admin_ip_cidrs) 0 }}[]{{ end }}
                                {{- range $admin_ip_cidr := $admin_ip_cidrs }}
                                    - {{ $admin_ip_cidr }}
                                {{- end }}

                        local-ip-only:
                            IPAllowList:
                                sourceRange:
                                    - {{ env "NOMAD_HOST_IP_https" }}

                        rewrite-security.txt-path-to-github:
                            replacePath:
                                path: /cloud-skeleton/packs-registry/refs/heads/main/packs/reverse_proxy/security/security.txt

                        security-headers:
                            headers:
                                browserXssFilter: true
                                contentTypeNosniff: true
                                forceStsHeader: true
                                frameDeny: true
                                stsIncludeSubdomains: true
                                stsPreload: true
                                stsSeconds: 31536000

                        success-response:
                            plugin:
                                static-response:
                                    fallback:
                                        statusCode: 200

                        traefik-dashboard-redirect:
                            redirectRegex:
                                permanent: true
                                regex: "^(.+)/$"
                                replacement: "$${1}/dashboard/"

                    routers:
                        security.txt-file:
                            middlewares:
                                - rewrite-security.txt-path-to-github
                            priority: 10001
                            rule: Path("/.well-known/security.txt")
                            service: github-raw-files

                        ssllabs-certificate-validation:
                            middlewares:
                                - success-response
                            priority: 10001
                            rule: Host("[[ var "traefik_hostname" . ]]") && ClientIP("{{ .ssllabs_cidr }}")
                            service: noop@internal

                        traefik-dashboard:
                            middlewares:
                                - admin-ip-only
                            priority: 10000
                            rule: Host("[[ var "traefik_hostname" . ]]") && (PathPrefix("/api/") || PathPrefix("/dashboard/"))
                            service: api@internal

                        traefik-dashboard-redirect:
                            middlewares:
                                - traefik-dashboard-redirect
                            priority: 10000
                            rule: Host("[[ var "traefik_hostname" . ]]") && Path("/")
                            service: noop@internal

                        traefik-ping:
                            middlewares:
                                - local-ip-only
                            priority: 10000
                            rule: Host("[[ var "traefik_hostname" . ]]") && Path("/ping")
                            service: ping@internal

                    serversTransports:
                        self-signed:
                            insecureSkipVerify: true

                    services:
                        github-raw-files:
                            loadBalancer:
                                passHostHeader: false
                                servers:
                                    - url: https://raw.githubusercontent.com

                tls:
                    options:
                        default:
                            cipherSuites:
                                - TLS_AES_256_GCM_SHA384
                                - TLS_CHACHA20_POLY1305_SHA256
                                - TLS_AES_128_GCM_SHA256
                                - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
                                - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
                                - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
                            curvePreferences:
                                - secp521r1
                                - secp384r1
                                - x25519
                                - secp256r1
                            minVersion: VersionTLS12
                            sniStrict: true
                ...
                {{- end }}
                EOF
                destination = "local/traefik_dynamic.yml"
            }

            volume_mount {
                destination = "/certificates"
                volume      = "certificates"
            }
        }

        volume "certificates" {
            access_mode     = "multi-node-multi-writer"
            attachment_mode = "file-system"
            read_only       = false
            source          = "[[ var "certificates_volume.id" . ]]"
            type            = "csi"
        }
    }

    meta = {
        [[- template "extra_pack_meta" . ]]

        // Dynamic configuration
        "params.config.admin_ip_cidrs" = "[]"
        "params.config.log_level"      = "INFO"
        "params.config.ssllabs_cidr"   = "69.67.183.0/24"

        // Docker images used in job
        "params.images.traefik" = "3.5.1"

        // Volumes
        "volumes.[[ var "certificates_volume.id" . ]].id"        = "[[ var "certificates_volume.id" . ]]"
        "volumes.[[ var "certificates_volume.id" . ]].name"      = "[[ var "certificates_volume.name" . ]]"
        "volumes.[[ var "certificates_volume.id" . ]].plugin_id" = "[[ var "certificates_volume.plugin_id" . ]]"
    }

    namespace = "system"
    type      = "system"

    update {
        auto_revert = true
    }
}
