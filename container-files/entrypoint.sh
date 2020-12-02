#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"
readonly _home_path="$(cd "${_dir}/.." && pwd)"/"${_HOME_DIR_NAME}"
readonly _cron_schedule_expression="${CRON_SCHEDULE_EXPRESSION:-"*/10 * * * *"}"
readonly _keep_out_of_sync_files="${KEEP_OUT_OF_SYNC_FILES:-false}"
readonly _exclude_old_logs="${EXCLUDE_OLD_LOGS:-false}"
readonly _enable_pa_sync="${FP_ENABLE_PA_SYNC:-false}"
readonly _enable_csg_sync="${FP_ENABLE_CSG_SYNC:-false}"

main() {
    rm "${_home_path}"/scripts/*.lock 2>/dev/null || true

    cat <<EOF >"/etc/crontab"
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# *  *  *  *  * user-name  command to be executed

EOF
    if test "${_enable_pa_sync}" = true; then
        local __pa_sync_dir="/forcepoint-logs/pa"
        if test "${_exclude_old_logs}" = true; then
            __pa_sync_dir="/forcepoint-logs/initial/pa"
            echo -e "0 3 * * * root ${_home_path}/scripts/clean-logs.sh" >>/etc/crontab
        fi
        echo -e "${_cron_schedule_expression} root ${_home_path}/scripts/start-sync-process-crond.sh ${PA_S3_URL} ${_keep_out_of_sync_files} ${_exclude_old_logs} ${__pa_sync_dir}" >>/etc/crontab
    fi

    if test "${_enable_csg_sync}" = true; then
        echo -e "${_cron_schedule_expression} root ${_home_path}/scripts/start-sync-process-crond.sh ${CSG_S3_URL} ${_keep_out_of_sync_files} ${_exclude_old_logs} /forcepoint-logs/csg" >>/etc/crontab
    fi
    echo -n >>/etc/crontab

    crond -n
}

main "$@"
