install_deps() {
    apk add sqlite jq > /dev/null
}

initialize() {
    if curl -fso /dev/null -u admin:admin "${GF_SERVER_ROOT_URL}/api/user"; then
        USER_ID="$(curl -fsu admin:admin "${GF_SERVER_ROOT_URL}/api/user" | jq '.id')"
        curl -fso /dev/null -u admin:admin -H 'Content-Type: application/json' -X PUT "${GF_SERVER_ROOT_URL}/api/users/${USER_ID}" \
            -d "{\"login\":\"${GRAFANA_USER}\"}"
        grafana cli admin reset-admin-password "${GRAFANA_PASSWORD}" --user-id "${USER_ID}" > /dev/null 2>&1
        SECRET_KEY="$(head -c 32 /dev/urandom | base64 -w 0)"
        STATE="$(curl -fs --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
        if [ $? != 0 ]; then
            STATE="{}"
        fi
        STATE="$(echo "${STATE}" | jq -c \
            --arg admin_id "${USER_ID}" \
            --arg secret_key "${SECRET_KEY}" \
            '.Items += {
                "grafana.admin_id": $admin_id,
                "grafana.secret_key": $secret_key
            }')"
        curl -fso /dev/null --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            -X PUT "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}" -d "${STATE}"
        echo 'Grafana has been initialized.'
        return 1
    fi
    return 0
}

set_credentials() {
    if ! curl -fso /dev/null -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" "${GF_SERVER_ROOT_URL}/api/user"; then
        STATE="$(curl -fs --unix-socket "${NOMAD_SECRETS_DIR}/api.sock" -H "Authorization: Bearer ${NOMAD_TOKEN}" \
            "http://localhost/v1/var/params/${NOMAD_JOB_NAME}/state?namespace=${NOMAD_NAMESPACE}")"
        eval "$(echo "${STATE}" | jq -r '.Items | {
            "USER_ID": .["grafana.admin_id"]
        } | to_entries[] | "\(.key)=\(.value | @sh)"')"
        sqlite3 -cmd '.timeout 10000' /var/lib/grafana/grafana.db \
            "UPDATE user SET login = '${GRAFANA_USER}' WHERE id = ${USER_ID}"
        grafana cli admin reset-admin-password "${GRAFANA_PASSWORD}" --user-id "${USER_ID}" > /dev/null 2>&1
        echo 'Credentials have been changed.'
    fi
}

wait_for_app() {
    while ! curl -fso /dev/null "${GF_SERVER_ROOT_URL}/api/health"; do
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