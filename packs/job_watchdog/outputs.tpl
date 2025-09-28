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

5. Create ACL policy to allow access to token (& other) variables:
cat << POLICY | nomad acl policy apply -namespace system -job [[ template "job_name" (list . "watcher") ]] \
    -description "Allow job watchdog initial access to variables" allow-watchdog-variables-read-write -
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
    -description "Allow job watchdog autoupdater access to other jobs' variables" \
    allow-watchdog-autoupdater-variables-read-write -
namespace "*" {
    policy = "read"

    variables {
        path "certs/ingress_to_service/*" {
            "capabilities" = [
                "list",
                "read",
                "write"
            ]
        }

        path "params/*/images" {
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