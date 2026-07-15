#!/usr/bin/env bash

JOB_MIN_HEALTHY_TIME=30
JOB_GROUP_RESTART_ATTEMPTS=2
JOB_GROUP_SERVICE_CHECK_INTERVAL=15
JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_LIMIT=4

APP_COLD_START=${1:-}

if [[ -z ${APP_COLD_START} ]]; then
    read -r -p "Enter expected app cold start time (in seconds): " APP_COLD_START
fi

# Keep restart.delay equal to the check interval. Nomad adds up to 25% jitter,
# so use the rounded-up maximum only for worst-case recovery calculations.
JOB_GROUP_RESTART_DELAY=${JOB_GROUP_SERVICE_CHECK_INTERVAL}
JOB_GROUP_RESTART_DELAY_MAX=$(( (JOB_GROUP_RESTART_DELAY * 125 + 99) / 100 ))

JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_GRACE=${APP_COLD_START}
JOB_GROUP_RESTART_CYCLE=$((
    JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_GRACE +
    JOB_GROUP_SERVICE_CHECK_INTERVAL * JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_LIMIT +
    JOB_GROUP_RESTART_DELAY_MAX
))
JOB_GROUP_UPDATE_HEALTHY_DEADLINE=$((
    JOB_GROUP_RESTART_ATTEMPTS * JOB_GROUP_RESTART_CYCLE +
    APP_COLD_START +
    JOB_GROUP_SERVICE_CHECK_INTERVAL +
    JOB_MIN_HEALTHY_TIME
))
JOB_GROUP_UPDATE_PROGRESS_DEADLINE=$((
    JOB_GROUP_UPDATE_HEALTHY_DEADLINE +
    2 * JOB_GROUP_SERVICE_CHECK_INTERVAL
))
JOB_GROUP_RESTART_INTERVAL=$((
    (JOB_GROUP_RESTART_ATTEMPTS + 1) * JOB_GROUP_RESTART_CYCLE
))

ceil_to_check_interval() {
    echo $((
        ($1 + JOB_GROUP_SERVICE_CHECK_INTERVAL - 1) /
        JOB_GROUP_SERVICE_CHECK_INTERVAL * JOB_GROUP_SERVICE_CHECK_INTERVAL
    ))
}

format_nomad_duration() {
    local seconds=$1
    local hours=$(( seconds / 3600 ))
    local minutes=$(( (seconds % 3600) / 60 ))
    local remaining_seconds=$(( seconds % 60 ))

    (( hours > 0 )) && printf '%sh' "${hours}"
    (( minutes > 0 )) && printf '%sm' "${minutes}"
    if (( remaining_seconds > 0 || (hours == 0 && minutes == 0) )); then
        printf '%ss' "${remaining_seconds}"
    fi
}

JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_GRACE=$(ceil_to_check_interval \
    "${JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_GRACE}")
JOB_GROUP_UPDATE_HEALTHY_DEADLINE=$(ceil_to_check_interval \
    "${JOB_GROUP_UPDATE_HEALTHY_DEADLINE}")
JOB_GROUP_UPDATE_PROGRESS_DEADLINE=$(ceil_to_check_interval \
    "${JOB_GROUP_UPDATE_PROGRESS_DEADLINE}")
JOB_GROUP_RESTART_INTERVAL=$(ceil_to_check_interval \
    "${JOB_GROUP_RESTART_INTERVAL}")

cat <<EOF
job "" {
  group "" {
    restart {
      attempts = ${JOB_GROUP_RESTART_ATTEMPTS}
      delay    = "$(format_nomad_duration "${JOB_GROUP_RESTART_DELAY}")"
      interval = "$(format_nomad_duration "${JOB_GROUP_RESTART_INTERVAL}")"
    }

    service {
      check {
        check_restart {
          grace = "$(format_nomad_duration "${JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_GRACE}")"
          limit = ${JOB_GROUP_SERVICE_CHECK_CHECK_RESTART_LIMIT}
        }

        interval = "$(format_nomad_duration "${JOB_GROUP_SERVICE_CHECK_INTERVAL}")"
      }
    }

    update {
      healthy_deadline  = "$(format_nomad_duration "${JOB_GROUP_UPDATE_HEALTHY_DEADLINE}")"
      progress_deadline = "$(format_nomad_duration "${JOB_GROUP_UPDATE_PROGRESS_DEADLINE}")"
    }
  }

  update {
    min_healthy_time = "$(format_nomad_duration "${JOB_MIN_HEALTHY_TIME}")"
  }
}
EOF
