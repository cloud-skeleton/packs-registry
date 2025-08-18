CSI volumes can be created with the Nomad CLI:

```
cat << VOL | nomad volume create -
id        = "{{ csi_volume_name }}"
name      = "{{ csi_volume_name }}"
plugin_id = "[[ var "id" . ]]"
type      = "csi"

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}
VOL
```

They can be destroyed with:
```
nomad volume delete "{{ csi_volume_name }}"
```

Or deregistered (to retain the underlying data) with:
```
nomad volume deregister "{{ csi_volume_name }}"
```
