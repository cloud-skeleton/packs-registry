initialize() {
    local CREDENTIALS_STATUS_CODE=$(curl -so /dev/null -w "%%{http_code}" \
        http://127.0.0.1:3000/api/user -u "admin:admin")
    if [[ $CREDENTIALS_STATUS_CODE == 200 ]]; then
        echo "${GRAFANA_PASSWORD}" | grafana cli admin reset-admin-password --password-from-stdin 2>/dev/null
        echo 'Grafana has been initialized.'
        return 1
    fi
    return 0
}

wait_for_app() {
    while ! curl -sf http://localhost:3000/api/health > /dev/null 2>&1; do
        sleep 5
    done
}

SLEEP_PID=
GOT_TERM=0
trap 'GOT_TERM=1; [ -n "${SLEEP_PID}" ] && kill "${SLEEP_PID}"' TERM

wait_for_app
if initialize; then
    echo "already ran!"
fi

(( GOT_TERM )) && exit 0
sleep infinity & SLEEP_PID=$!
wait "${SLEEP_PID}"
exit 0
