job "[[ meta "pack.name" . ]]-ingress_load_balancer-[[ var "id" . ]]" {
    constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "ingress-worker"
    }

    group "traefik" {
        network {
            mode = "cni/bridge"

            port "http" {
                static = 80
            }

            port "https" {
                static = 443
            }
        }

        // service {
        //     name = "traefik"

        //     check {
        //         interval = "10s"
        //         name     = "alive"
        //         port     = "http"
        //         timeout  = "2s"
        //         type     = "tcp"
        //     }
        // }

        task "service" {
            config {
                cpu_hard_limit = true
                image          = "traefik:v[[ var "traefik_version" . ]]"
                ports = [
                    "http",
                    "https"
                ]
                volumes = [
                    "local/traefik_dynamic.yml:/etc/traefik/dynamic.yml",
                    "local/traefik_static.yml:/etc/traefik/traefik.yml"
                ]
            }

            driver = "docker"

            resources {
                cpu    = 1000
                memory = 32
            }

            template {
                data = <<-EOF
                ---
                api: {}
                #certificatesResolvers:
                #  lets-encrypt:
                #    acme:
                #      dnsChallenge:
                #        provider: ${DNS_PROVIDER}
                #      email: ${CERTIFICATE_EMAIL}
                #      keyType: EC384
                #      storage: /certificates/acme.json
                entrypoints:
                http:
                    address: :{{ env "NOMAD_ADDR_http" }}
                    http:
                    encodeQuerySemicolons: true
                    redirections:
                        entryPoint:
                        permanent: true
                        to: https
                    http3: {}
                    reusePort: true
                https:
                    address: :{{ env "NOMAD_ADDR_https" }}
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
                level: INFO
                ping:
                manualRouting: true
                #providers:
                #  file:
                #    filename: /etc/traefik/dynamic.yml
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
                        sourceRange:
                        - ${ADMIN_ALLOW_IP_CIDR_1}
                        - ${ADMIN_ALLOW_IP_CIDR_2}

                    local-ip-only:
                    IPAllowList:
                        sourceRange:
                        - 127.0.0.0/8
                        - ::1/128
                        - ${TRAEFIK_PRIVATE_IP}

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
                    rule: >
                        Host("${TRAEFIK_HOSTNAME}") && ClientIP("${SSL_LABS_CIDR}")
                    service: noop@internal

                    traefik-dashboard:
                    middlewares:
                        - admin-ip-only
                    priority: 1000
                    rule: >
                        Host("${TRAEFIK_HOSTNAME}") && (PathPrefix("/api/") || PathPrefix("/dashboard/"))
                    service: api@internal

                    traefik-dashboard-redirect:
                    middlewares:
                        - traefik-dashboard-redirect
                    priority: 1000
                    rule: Host("${TRAEFIK_HOSTNAME}") && Path("/")
                    service: noop@internal

                    traefik-ping:
                    middlewares:
                        - local-ip-only
                    priority: 1000
                    rule: Host("${TRAEFIK_HOSTNAME}") && Path("/ping")
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
