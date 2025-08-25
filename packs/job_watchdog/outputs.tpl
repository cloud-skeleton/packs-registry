1. Create new management token:
TOKEN=$(nomad acl token create -type management -name "nomad-job-watchdog" | grep "Secret ID" | grep -oP "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")

2. Set it as variable:
nomad var put -force -namespace=system system/tools/nomad-job-watchdog/secrets NOMAD_TOKEN=${TOKEN}

3. Create ACL policy to allow access to token (& other) variables:
cat << POLICY | nomad acl policy apply -namespace system -job [[ template "job_name" (list . "watcher") ]] -description "Allow Nomad job watchdog variables read & write access" allow-watchdog-variables-read-write -
namespace "system" {
    policy = "read"

    variables {
        path "system/tools/nomad-job-watchdog/*" {
            "capabilities" = [
                "list",
                "read",
                "write"
            ]
        }
    }
}
POLICY
