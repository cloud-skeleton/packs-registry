install_deps() {
    apk add sqlite openssl jq > /dev/null
}

initialize() {
    local CREDENTIALS_STATUS_CODE=$(curl -so /dev/null -u admin:admin -w "%%{http_code}" http://localhost:3000/api/user)
    if [[ $CREDENTIALS_STATUS_CODE == 200 ]]; then
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

    # local CURRENT_USERNAME CURRENT_PASSWORD_HASH SALT
    # read -r CURRENT_USERNAME CURRENT_PASSWORD_HASH SALT < <(
    #     sqlite3 -separator ' ' -cmd '.timeout 10000' /var/lib/grafana/grafana.db \
    #         "SELECT login, password, salt FROM user WHERE id=1"
    # )
    # local NEW_PASSWORD_HASH="$(openssl kdf -keylen 50 -kdfopt digest:SHA256 -kdfopt iter:10000 \
    #     -kdfopt pass:"${GRAFANA_PASSWORD}" -kdfopt salt:"${SALT}" PBKDF2 | tr -d ':\n' | tr 'A-F' 'a-f')"
    # if [ "${CURRENT_PASSWORD_HASH}" != "${NEW_PASSWORD_HASH}" ]; then
        
    # fi
}

wait_for_app() {
    while ! curl -sf http://localhost:3000/api/health > /dev/null 2>&1; do
        sleep 5
    done
}

SLEEP_PID=
GOT_TERM=0
trap 'GOT_TERM=1; [ -n "${SLEEP_PID}" ] && kill "${SLEEP_PID}"' TERM

install_deps
wait_for_app
if initialize; then
    echo "already ran!"
fi

(( GOT_TERM )) && exit 0
sleep infinity & SLEEP_PID=$!
wait "${SLEEP_PID}"
exit 0
