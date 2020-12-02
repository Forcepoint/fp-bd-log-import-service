#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"
readonly _home_folder="$(cd "${_dir}/.." && pwd)"
readonly _keep_out_of_sync_files="${KEEP_OUT_OF_SYNC_FILES:-false}"
readonly _exclude_old_logs="${EXCLUDE_OLD_LOGS:-false}"
readonly _enable_pa_sync="${FP_ENABLE_PA_SYNC:-false}"
readonly _enable_csg_sync="${FP_ENABLE_CSG_SYNC:-false}"

validate_prerequisites() {
    local __r=0
    local __prerequisites=("$@")
    local __clear_previous_display="\r\033[K"
    for prerequisite in "${__prerequisites[@]}"; do
        echo -en "${__clear_previous_display}Prerequisite - ${prerequisite} - check" && sleep 0.1
        command -v ${prerequisite} >/dev/null 2>&1 || {
            echo -e "${__clear_previous_display}We require >>> ${prerequisite} <<< but it's not installed. Please try again after installing ${prerequisite}." &&
                __r=1 &&
                break
        }
    done
    echo -en "${__clear_previous_display}"
    return "${__r}"
}

setup_systemd_exec_variables() {
    local -r __systemd_file="${1}"
    local -r __variables="${2}"
    local __r=1
    local __content="$(awk '{gsub(/ExecStart=.*$/,"ExecStart=/bin/bash -c \x27 ${APP_HOME}/scripts/start-sync-process-sysd.sh '"${__variables}"'\x27''")}1' "${__systemd_file}")"
    echo "${__content}" >"${__systemd_file}" && __r=0
    return "${__r}"
}

setup_systemd_home_dir() {
    local -r __systemd_file="${1}"
    local -r __home_dir="${2}"
    local -r __home_dir_variable_name="${3}"
    local -r __user="${4}"
    local __r=1
    local __content="$(awk '{gsub(/Environment=.*$/,"Environment='"${__home_dir_variable_name}"'='"${__home_dir}"'")}1' "${__systemd_file}")"
    echo "${__content}" >"${__systemd_file}" && __r=0
    __content="$(awk '{gsub(/WorkingDirectory=.*$/,"WorkingDirectory='"${__home_dir}"'")}1' "${__systemd_file}")"
    echo "${__content}" >"${__systemd_file}" && __r=0
    __content="$(awk '{gsub(/User=.*$/,"User='"${__user}"'")}1' "${__systemd_file}")"
    echo "${__content}" >"${__systemd_file}" && __r=0
    return "${__r}"
}

deploy() {
    local -r __service_name="${1}"
    cd "${_dir}"
    sudo cp -f ./"${__service_name}" /etc/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl start "${__service_name}"
    sudo systemctl enable "${__service_name}"
}

main() {
    cd "${_dir}"
    local __prerequisites=(systemctl rsync)
    local __home_dir_variable_name="APP_HOME"
    validate_prerequisites "${__prerequisites[@]}"
    local -r __user="$(whoami)"
    sudo chown -R "${__user}": "${_home_folder}"
    sudo mkdir -p /forcepoint-logs/pa /forcepoint-logs/csg /forcepoint-logs/initial/pa "${_home_folder}"/logs
    sudo chown -R "${__user}": "${_home_folder}" /forcepoint-logs
    sudo cp -rf "${_home_folder}"/.aws ~ 2> /dev/null
    sudo chown -R "${__user}": ~/.aws
    sudo chmod ugo+rw "${_dir}"/*.service

    for _sysd_file in "${_dir}"/*.service; do
        setup_systemd_home_dir "${_sysd_file}" "${_home_folder}" "${__home_dir_variable_name}" "${__user}"
    done

    local __pa_sync_dir="/forcepoint-logs/pa"
    if test "${_enable_pa_sync}" = true; then
        if test "${_exclude_old_logs}" = true; then
            __pa_sync_dir="/forcepoint-logs/initial/pa"
            deploy "fp-clean-recent-logs.service"
            deploy "fp-clean-recent-logs.timer"
        fi
        setup_systemd_exec_variables "${_dir}/fp-pa-aws-log-service.service" "${PA_S3_URL} ${_keep_out_of_sync_files} ${_exclude_old_logs} ${__pa_sync_dir}"
        deploy "fp-pa-aws-log-service.service"
        deploy "fp-pa-aws-log-service-timer.service"
    fi

    if test "${_enable_csg_sync}" = true; then
        setup_systemd_exec_variables "${_dir}/fp-csg-aws-log-service.service" "${CSG_S3_URL} ${_keep_out_of_sync_files} ${_exclude_old_logs} /forcepoint-logs/csg"
        deploy "fp-csg-aws-log-service.service"
        deploy "fp-csg-aws-log-service-timer.service"
    fi

    sudo rm -rf "${_home_folder}"/.aws 2> /dev/null
}

main "$@"
