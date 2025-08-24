```
nomad acl policy apply -namespace system -job job_autoacl-watcher-main test policy.json
```
```
nomad acl token create -type management -name "nomad-job-var-autoacl"
```
```
nomad var put -force -namespace=system system/tools/nomad-job-var-autoacl/token \
    NOMAD_TOKEN={management token}
```