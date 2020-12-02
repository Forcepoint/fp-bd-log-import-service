#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly _scripts_dir="$(cd "$(dirname "${0}")" && pwd)"
readonly _s3_url="${1}"
readonly _keep_out_of_sync_files="${2:-false}"
readonly _exclude_old_logs="${3:-false}"
readonly _aws_sync_dir="${4:-"/forcepoint-logs/pa"}"

start-sync-process() {

    local __aws_profile="pa"
    
    if [[ "${_aws_sync_dir}" == "/forcepoint-logs/csg" ]]; then
        __aws_profile="csg"
    fi

    if test "${_keep_out_of_sync_files}" = true; then
        /usr/local/bin/aws s3 sync "${_s3_url}" "${_aws_sync_dir}" --profile "${__aws_profile}" 2> "${_scripts_dir}"/../logs/"${__aws_profile}"-sync-errors.log
    else
        /usr/local/bin/aws s3 sync "${_s3_url}" "${_aws_sync_dir}" --delete --profile "${__aws_profile}" 2> "${_scripts_dir}"/../logs/"${__aws_profile}"-sync-errors.log
    fi

    if test "${_exclude_old_logs}" = true; then
        "${_scripts_dir}"/start-sync-todays-logs.sh
    fi
}
