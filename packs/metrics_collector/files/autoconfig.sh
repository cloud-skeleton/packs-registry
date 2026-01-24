duration_to_seconds() {
    local DURATION="$1"
    local SECONDS=0
    local NUM
    local UNIT
    local REST
    while [[ $DURATION =~ ^([0-9]+)([smhdw])(.*)$ ]]; do
        NUM=${BASH_REMATCH[1]}
        UNIT=${BASH_REMATCH[2]}
        REST=${BASH_REMATCH[3]}
        case "$UNIT" in
            s) SECONDS=$((SECONDS + NUM)) ;;
            m) SECONDS=$((SECONDS + NUM * 60)) ;;
            h) SECONDS=$((SECONDS + NUM * 3600)) ;;
            d) SECONDS=$((SECONDS + NUM * 86400)) ;;
            w) SECONDS=$((SECONDS + NUM * 604800)) ;;
        esac
        DURATION="${REST}"
    done
    echo "${SECONDS}"
}

initialize() {
    if curl -s http://127.0.0.1:8086/api/v2/setup | grep -q '"allowed": true'; then
        export INFLUX_TOKEN=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
        influx setup \
            -u "${INFLUX_USER}" \
            -p "${INFLUX_PASSWORD}" \
            -t "${INFLUX_TOKEN}" \
            -o "${INFLUX_ORGANIZATION}" \
            -b nomad \
            -r "${INFLUX_DATA_RETENTION}" -f > /dev/null
        local ORG_ID=$(influx org ls -n "${INFLUX_ORGANIZATION}" --hide-headers | awk '{ print $1 }')
        local USER_ID=$(influx user ls -n "${INFLUX_USER}" --hide-headers | awk '{ print $1 }')
        local NOMAD_BUCKET_ID=$(influx bucket ls -n nomad --org-id ${ORG_ID} --hide-headers | awk '{ print $1 }')
        local TELEGRAF_TOKEN_DATA="$(influx auth create --org-id ${ORG_ID} -d "Telegraf's Token" --write-bucket ${NOMAD_BUCKET_ID} --json)"
        local TELEGRAF_TOKEN="$(echo "$TELEGRAF_TOKEN_DATA" | grep -oE '"token":\s*"[^"]+"' | cut -d' :' -f2 | tr -d '"')"
        curl -so /dev/null --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" \
            -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            -X PUT "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}" \
            --data "{\"Namespace\":\"${NOMAD_NAMESPACE}\",\"Items\":\
            {\"nomad_bucket_id\":\"${NOMAD_BUCKET_ID}\",\
            \"org_id\":\"${ORG_ID}\",\"admin_token\":\"${INFLUX_TOKEN}\",\"telegraf_token\":\"${TELEGRAF_TOKEN}\",\
            \"user_id\":\"${USER_ID}\"}}"
        echo 'Database has been initialized.'
        return 1
    fi
    return 0
}

set_bucket_retention() {
    local STATE=$(curl -s --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" \
        -H "Authorization: Bearer ${NOMAD_TOKEN}" \
        "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")
    export INFLUX_TOKEN=$(echo "$STATE" | grep -oE '"admin_token":"[0-9a-zA-Z]+"' | cut -d':' -f2 | tr -d '"')
    local BUCKET_ID=$(echo "$STATE" | grep -oE '"nomad_bucket_id":"[0-9a-f]+"' | cut -d':' -f2 | tr -d '"')
    local ORG_ID=$(echo "$STATE" | grep -oE '"org_id":"[0-9a-f]+"' | cut -d':' -f2 | tr -d '"')
    local BUCKET_RETENTION=$(influx bucket ls --org-id ${ORG_ID} -i ${BUCKET_ID} --hide-headers | awk '{ print $3 }')
    if [ $(duration_to_seconds ${BUCKET_RETENTION}) != $(duration_to_seconds ${INFLUX_DATA_RETENTION}) ]; then
        influx bucket update -i ${BUCKET_ID} -r "${INFLUX_DATA_RETENTION}" > /dev/null
        echo 'Bucket retention has been changed.'
    fi
}

set_organization_name() {
    local STATE=$(curl -s --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" \
        -H "Authorization: Bearer ${NOMAD_TOKEN}" \
        "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")
    export INFLUX_TOKEN=$(echo "$STATE" | grep -oE '"admin_token":"[0-9a-zA-Z]+"' | cut -d':' -f2 | tr -d '"')
    local ORG_ID=$(echo "$STATE" | grep -oE '"org_id":"[0-9a-f]+"' | cut -d':' -f2 | tr -d '"')
    if [ "$(influx org ls -i ${ORG_ID} --hide-headers | awk '{ print $2 }')" != "${INFLUX_ORGANIZATION}" ]; then
        influx org update -i ${ORG_ID} -n "${INFLUX_ORGANIZATION}" > /dev/null
        echo 'Organization name has been changed.'
    fi
}

set_user_name() {
    local STATE=$(curl -s --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" \
        -H "Authorization: Bearer ${NOMAD_TOKEN}" \
        "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")
    export INFLUX_TOKEN=$(echo "$STATE" | grep -oE '"admin_token":"[0-9a-zA-Z]+"' | cut -d':' -f2 | tr -d '"')
    local USER_ID=$(echo "$STATE" | grep -oE '"user_id":"[0-9a-f]+"' | cut -d':' -f2 | tr -d '"')
    if [ "$(influx user ls -i ${USER_ID} --hide-headers | awk '{ print $2 }')" != "${INFLUX_USER}" ]; then
        influx user update -i ${USER_ID} -n "${INFLUX_USER}" > /dev/null
        echo 'User name has been changed.'
    fi
}

set_user_password() {
    local STATE=$(curl -s --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" \
        -H "Authorization: Bearer ${NOMAD_TOKEN}" \
        "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")
    export INFLUX_TOKEN=$(echo "$STATE" | grep -oE '"admin_token":"[0-9a-zA-Z]+"' | cut -d':' -f2 | tr -d '"')
    local USER_ID=$(echo "$STATE" | grep -oE '"user_id":"[0-9a-f]+"' | cut -d':' -f2 | tr -d '"')
    local CREDENTIALS_STATUS_CODE=$(curl -so /dev/null -w "%%{http_code}" \
        -X POST http://127.0.0.1:8086/api/v2/signin \
        -u "${INFLUX_USER}:${INFLUX_PASSWORD}")
    if [[ $CREDENTIALS_STATUS_CODE == 401 ]]; then
        influx user password -i ${USER_ID} -p "${INFLUX_PASSWORD}" > /dev/null
        echo 'User password has been changed.'
    fi
}

wait_for_db() {
    while ! influx ping > /dev/null 2>&1; do
        sleep 5
    done
}

SLEEP_PID=
GOT_TERM=0
trap 'GOT_TERM=1; [ -n "${SLEEP_PID}" ] && kill "${SLEEP_PID}"' TERM

wait_for_db
if initialize; then
    set_user_name
    set_user_password
    set_organization_name
    set_bucket_retention
fi

(( GOT_TERM )) && exit 0
sleep infinity & SLEEP_PID=$!
wait "${SLEEP_PID}"
exit 0
