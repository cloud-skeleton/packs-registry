1. Configure secrets:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "ingester") ]]/secrets \
    admin_user=${ADMIN_USER} \
    admin_password=${ADMIN_PASSWORD}