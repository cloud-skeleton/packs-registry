```
cat << POLICY | nomad acl policy apply -namespace system -job [[ template "job_name" (list . "watcher") ]] -description "Allow Nomad job AutoACL variables access" allow-autoacl-var-read -
{
    "namespace": {
        "*": {
            "policy": "read",
            "variables": {
                "path": {
                    "system/tools/nomad-job-var-autoacl/*": {
                        "capabilities": [
                            "list",
                            "read",
                            "write"
                        ]
                    }
                }
            }
        }
    }
}
POLICY
```
```
nomad acl token create -type management -name "nomad-job-var-autoacl"
```
```
nomad var put -force -namespace=system system/tools/nomad-job-var-autoacl/token \
    NOMAD_TOKEN={management token}
```