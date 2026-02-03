install_deps() {
    apk add jq > /dev/null
}

initialize() {
    if curl -s http://127.0.0.1:8086/api/v2/setup | grep -q '"allowed": true'; then
        export INFLUX_TOKEN="$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)"
        influx setup \
            -u "${INFLUX_USER}" \
            -p "${INFLUX_PASSWORD}" \
            -t "${INFLUX_TOKEN}" \
            -o "${INFLUX_ORGANIZATION}" \
            -b nomad \
            -r "${INFLUX_DATA_RETENTION}" -f > /dev/null
        local ORG_ID="$(influx org ls -n "${INFLUX_ORGANIZATION}" --json | jq -r '.[0] .id')"
        local USER_ID="$(influx user ls -n "${INFLUX_USER}" --json | jq -r '.[0] .id')"
        local NOMAD_BUCKET_ID="$(influx bucket ls -n nomad --org-id "${ORG_ID}" --json | jq -r '.[0] .id')"
        local TELEGRAF_TOKEN="$(influx auth create --org-id "${ORG_ID}" -d "Telegraf's Token" --write-buckets --json | jq -r '.token')"
        local GRAFANA_TOKEN="$(influx auth create --org-id "${ORG_ID}" -d "Grafana's Token" --read-buckets --json | jq -r '.token')"
        local STATE="$(curl -sf --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
        if [ $? != 0 ]; then
            STATE="{}"
        fi
        STATE="$(echo "${STATE}" | jq -c \
            --arg admin_id "${USER_ID}" \
            --arg admin_token "${INFLUX_TOKEN}" \
            --arg grafana_token "${GRAFANA_TOKEN}" \
            --arg nomad_bucket_id "${NOMAD_BUCKET_ID}" \
            --arg organisation_id "${ORG_ID}" \
            --arg telegraf_token "${TELEGRAF_TOKEN}" \
            '.Items += {
                "influxdb.admin_id": $admin_id,
                "influxdb.admin_token": $admin_token,
                "influxdb.grafana_token": $grafana_token,
                "influxdb.nomad_bucket_id": $nomad_bucket_id,
                "influxdb.organisation_id": $organisation_id,
                "influxdb.telegraf_token": $telegraf_token
            }')"
        curl -so /dev/null --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            -X PUT "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}" -d "${STATE}"
        echo 'InfluxDB has been initialized.'
        return 1
    fi
    return 0
}

set_bucket_retention() {
    local STATE="$(curl -sf --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
        "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
    eval "$(echo "${STATE}" | jq -r '.Items | {
        "export INFLUX_TOKEN": .["influxdb.admin_token"],
        "local BUCKET_ID": .["influxdb.nomad_bucket_id"],
        "local ORG_ID": .["influxdb.organisation_id"]
    } | to_entries[] | "\(.key)=\(.value | @sh)"')"
    local BUCKET_RETENTION="$(influx bucket ls --org-id "${ORG_ID}" -i "${BUCKET_ID}" --json \
        | jq -r '.[0] .retentionRules .[0] .everySeconds')"
    if [ "${BUCKET_RETENTION}" != "${INFLUX_DATA_RETENTION}" ]; then
        influx bucket update -i "${BUCKET_ID}" -r "${INFLUX_DATA_RETENTION}" > /dev/null
        echo 'Bucket retention has been changed.'
    fi
}

set_organization_name() {
    local STATE="$(curl -sf --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
        "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
    eval "$(echo "${STATE}" | jq -r '.Items | {
        "export INFLUX_TOKEN": .["influxdb.admin_token"],
        "local ORG_ID": .["influxdb.organisation_id"]
    } | to_entries[] | "\(.key)=\(.value | @sh)"')"
    if [ "$(influx org ls -i "${ORG_ID}" --json | jq -r '.[0] .name')" != "${INFLUX_ORGANIZATION}" ]; then
        influx org update -i "${ORG_ID}" -n "${INFLUX_ORGANIZATION}" > /dev/null
        echo 'Organization name has been changed.'
    fi
}

set_credentials() {
    if ! curl -sfo /dev/null -u "${INFLUX_USER}:${INFLUX_PASSWORD}" -X POST http://127.0.0.1:8086/api/v2/signin; then
        local STATE="$(curl -sf --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
        eval "$(echo "${STATE}" | jq -r '.Items | {
            "export INFLUX_TOKEN": .["influxdb.admin_token"],
            "local USER_ID": .["influxdb.admin_id"]
        } | to_entries[] | "\(.key)=\(.value | @sh)"')"
        influx user update -i "${USER_ID}" -n "${INFLUX_USER}" > /dev/null
        influx user password -i "${USER_ID}" -p "${INFLUX_PASSWORD}" > /dev/null
        echo 'Credentials have been changed.'
    fi
}

wait_for_app() {
    while ! influx ping > /dev/null 2>&1; do
        sleep 5
    done
}

SLEEP_PID=
GOT_TERM=0
trap 'GOT_TERM=1; [ -n "${SLEEP_PID}" ] && kill "${SLEEP_PID}"' TERM

install_deps
wait_for_app
if initialize; then
    set_credentials
    set_organization_name
    set_bucket_retention
fi

(( GOT_TERM )) && exit 0
sleep infinity & SLEEP_PID=$!
wait "${SLEEP_PID}"
exit 0