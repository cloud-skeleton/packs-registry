1. Create new management token:
TOKEN=$(nomad acl token create -type management -name "nomad-job-watchdog" | grep "Secret ID" | grep -oP "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")

2. Set it as variable:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "watcher") ]]/secrets \
    nomad_token=${TOKEN}

3. Set images variable:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "watcher") ]]/images \
    ghcr.io/cloud-skeleton/nomad-job-watchdog=v1.2

4. Set config variable:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "watcher") ]]/config \
    parameters_meta_prefix=params parameters_root_path=params volumes_meta_prefix=volumes

nomad var put -force -namespace=system params/[[ template "job_name" (list . "autoupdater") ]]/config \
    ingress_worker_ips=$(nomad node status -filter 'NodeClass == "ingress-worker"' -json \
    | jq -c '[.[] .Address]') \
    main_worker_ips=$(nomad node status -filter 'NodeClass == "main-worker"' -json \
    | jq -c '[.[] .Address]')

5. Create ACL policy to allow access to token (& other) variables:
cat << POLICY | nomad acl policy apply -namespace system -job [[ template "job_name" (list . "watcher") ]] \
    -description [[ template "job_policy_description" (list . "watcher") ]] \
    [[ template "job_policy_name" (list . "watcher") ]] -
namespace "system" {
    policy = "read"

    variables {
        path "params/[[ template "job_name" (list . "watcher") ]]/*" {
            "capabilities" = [
                "list",
                "read"
            ]
        }

        path "params/[[ template "job_name" (list . "watcher") ]]/state" {
            "capabilities" = [
                "write"
            ]
        }
    }
}
POLICY

cat << POLICY | nomad acl policy apply -namespace system -job [[ template "job_name" (list . "autoupdater") ]] \
    -description [[ template "job_policy_description" (list . "autoupdater") ]] \
    [[ template "job_policy_name" (list . "autoupdater") ]] -
namespace "*" {
    policy = "read"

    variables {       
        path "params/*/images" {
            "capabilities" = [
                "list",
                "read",
                "write"
            ]
        }
    }
}

namespace "system" {
    policy = "read"

    variables {
        path "certs/ingress_to_main/ca" {
            "capabilities" = [
                "list",
                "read",
                "write"
            ]
        }
        
        path "certs/ingress_to_main/ingress" {
            "capabilities" = [
                "list",
                "read",
                "write"
            ]
        }

        path "certs/ingress_to_main/main" {
            "capabilities" = [
                "list",
                "read",
                "write"
            ]
        }
    }
}
POLICY

6. Trigger auto-updater job to generate certificates and update Docker image tags:
nomad job periodic force -namespace system [[ template "job_name" (list . "autoupdater") ]]