#!/usr/bin/env bash
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -o errexit
set -o pipefail
set -o nounset

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"
readonly _aws_product_sync_dir="${4:-"/forcepoint-logs/pa"}"

source "${_dir}"/sync-process-util.sh

main() {

    _lock_file="${_dir}"/pa.lock
    if [[ "${_aws_product_sync_dir}" == "/forcepoint-logs/pa" ]]; then
        if [ -f "${_lock_file}" ]; then
            echo "A PA instance of this script is already running"
            exit 0
        fi
    else
        _lock_file="${_dir}"/csg.lock
        if [ -f "${_lock_file}" ]; then
            echo "A CSG instance of this script is already running"
            exit 0
        fi
    fi

    echo "Locked" > "${_lock_file}"

    start-sync-process "$@"

    rm "${_lock_file}"
}

main "$@"
