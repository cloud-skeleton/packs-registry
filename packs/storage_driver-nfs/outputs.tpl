1. Configure server NFS share:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "csi_plugin") ]]/secrets \
    nfs_share=${NFS_SHARE}
