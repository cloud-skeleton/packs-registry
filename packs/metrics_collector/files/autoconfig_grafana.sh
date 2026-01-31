install_deps() {
    apk add sqlite jq > /dev/null
}

initialize() {
    if curl -sfo /dev/null -u admin:admin http://localhost:3000/api/user; then
        local USER_ID="$(curl -su admin:admin http://localhost:3000/api/user | jq '.id')"
        curl -so /dev/null -u admin:admin -H 'Content-Type: application/json' -X PUT "http://localhost:3000/api/users/${USER_ID}" \
            -d "{\"login\":\"${GRAFANA_USER}\"}"
        grafana cli admin reset-admin-password "${GRAFANA_PASSWORD}" --user-id "${USER_ID}" > /dev/null 2>&1
        local STATE="$(curl -sf --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
        if [ $? != 0 ]; then
            STATE="{}"
        fi
        STATE="$(echo "${STATE}" | jq -c --arg user_id "${USER_ID}" '.Items += { "grafana.admin_id": $user_id }')"
        curl -so /dev/null --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            -X PUT "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}" -d "${STATE}"
        echo 'Grafana has been initialized.'
        return 1
    fi
    return 0
}

set_credentials() {
    if ! curl -sfo /dev/null -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" http://localhost:3000/api/user; then
        local STATE="$(curl -sf --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
        local USER_ID="$(echo "${STATE}" | jq -r '.Items ."grafana.admin_id"')"
        sqlite3 -cmd '.timeout 10000' /var/lib/grafana/grafana.db \
            "UPDATE user SET login = '${GRAFANA_USER}' WHERE id = ${USER_ID}"
        grafana cli admin reset-admin-password "${GRAFANA_PASSWORD}" --user-id "${USER_ID}" > /dev/null 2>&1
        echo 'Credentials have been changed.'
    fi
}

wait_for_app() {
    while ! curl -sfo /dev/null http://localhost:3000/api/health; do
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
fi

(( GOT_TERM )) && exit 0
sleep infinity & SLEEP_PID=$!
wait "${SLEEP_PID}"
exit 0