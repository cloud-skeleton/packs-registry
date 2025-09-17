1. Configure secrets:
nomad var put -force -namespace=system params/[[ template "job_name" (list . "ingester") ]]/secrets \
    user=${ADMIN_USER} \
    password=${ADMIN_PASSWORD} \
    token=${TOKEN}