```
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
```
```
nomad acl token create -type management -name "nomad-job-watchdog"
```
```
nomad var put -force -namespace=system system/tools/nomad-job-watchdog/token \
    NOMAD_TOKEN={management token}
```