job "[[ template "job_name" (list . "ingress_load_balancer") ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "ingress-worker"
    }

    group "traefik" {
        network {
            // @TODO: Can't use any other name because of https://github.com/hashicorp/nomad/issues/16455
            mode = "cni/nomad"

            port "http" {
                static = 80
            }

            port "https" {
                static = 443
            }
        }

        service {
            address = "[[ var "traefik_hostname" . ]]"

            check {
                check_restart {
                    limit = 3
                    grace = "2m"
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
                image          = "traefik:v[[ var "traefik_version" . ]]"

                mount {
                    type     = "bind"
                    target   = "/etc/traefik/dynamic.yml"
                    source   = "local/traefik_dynamic.yml"
                    readonly = true
                }

                mount {
                    type     = "bind"
                    target   = "/etc/traefik/traefik.yml"
                    source   = "local/traefik_static.yml"
                    readonly = true
                }

                ports = [
                    "http",
                    "https"
                ]
            }

            driver = "docker"

            resources {
                cpu    = 100
                memory = 64
            }

            template {
                data = <<-EOF
                {{- with nomadVar "nomad/jobs/[[ template "job_name" (list . "ingress_load_balancer") ]]/traefik/service/dns" }}
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
                ---
                api: {}
                certificatesResolvers:
                    lets-encrypt:
                        acme:
                            dnsChallenge:
                                provider: [[ var "dns_provider" . ]]
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
                    level: [[ var "log_level" . ]]
                ping:
                    manualRouting: true
                providers:
                    file:
                        filename: /etc/traefik/dynamic.yml
                ...
                EOF
                destination = "local/traefik_static.yml"
            }

            template {
                data = <<-EOF
                ---
                http:
                    middlewares:
                        admin-ip-only:
                            IPAllowList:
                                sourceRange: [[ if eq (len (var "admin_ip_cidrs" .)) 0 ]][][[ end ]]
                                [[- if gt (len (var "admin_ip_cidrs" .)) 0 ]]
                                [[- range $cidr := var "admin_ip_cidrs" . ]]
                                    - [[ $cidr ]]
                                [[- end ]]
                                [[- end ]]

                        local-ip-only:
                            IPAllowList:
                                sourceRange:
                                    - {{ env "NOMAD_HOST_IP_https" }}

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
                        ssllabs-certificate-validation:
                            middlewares:
                                - success-response
                            priority: 1000
                            rule: Host("[[ var "traefik_hostname" . ]]") && ClientIP("64.41.200.0/24")
                            service: noop@internal

                        traefik-dashboard:
                            middlewares:
                                - admin-ip-only
                            priority: 1000
                            rule: Host("[[ var "traefik_hostname" . ]]") && (PathPrefix("/api/") || PathPrefix("/dashboard/"))
                            service: api@internal

                        traefik-dashboard-redirect:
                            middlewares:
                                - traefik-dashboard-redirect
                            priority: 1000
                            rule: Host("[[ var "traefik_hostname" . ]]") && Path("/")
                            service: noop@internal

                        traefik-ping:
                            middlewares:
                                - local-ip-only
                            priority: 1000
                            rule: Host("[[ var "traefik_hostname" . ]]") && Path("/ping")
                            service: ping@internal

                    serversTransports:
                        self-signed:
                            insecureSkipVerify: true

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
            source          = "[[ var "certificates_volume_id" . ]]"
            type            = "csi"
        }
    }

    namespace = "system"
    type      = "system"
}
