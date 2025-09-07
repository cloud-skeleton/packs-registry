1. Create new management token:
TOKEN=$(nomad acl token create -type management -name "nomad-job-watchdog" | grep "Secret ID" | grep -oP "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")

2. Set it as variable:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "watcher") ]]/secrets \
    nomad_token=${TOKEN}

nomad var put -force -namespace=system params/[[ template "job_name" (list . "autoupdater") ]]/secrets \
    nomad_token=${TOKEN}

3. Set images variable:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "watcher") ]]/images \
    ghcr.io/cloud-skeleton/nomad-job-watchdog=v1.2

nomad var put -force -namespace=system params/[[ template "job_name" (list . "autoupdater") ]]/images \
    ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater=v1.0

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
