# #!/usr/bin/env bash
# SHELL=/bin/bash
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# set -o errexit
# set -o pipefail
# set -o nounset

# readonly _dir="$(cd "$(dirname "${0}")" && pwd)"
# readonly _s3_url="${1}"
# readonly _keep_out_of_sync_files="${2:-false}"
# readonly _exclude_old_logs="${3:-false}"

# main() {
#     _lock_file="${_dir}"/a.lock
#     if [ -f "${_lock_file}" ]; then
#         echo "An instance of this script is already running"
#         exit 0
#     fi

#     echo "Locked" > "${_lock_file}"

#     if test "${_keep_out_of_sync_files}" = true; then
#         /usr/local/bin/aws s3 sync "${_s3_url}" /aws 2> "${_dir}"/../logs/sync-errors.log
#     else
#         /usr/local/bin/aws s3 sync "${_s3_url}" /aws --delete 2> "${_dir}"/../logs/sync-errors.log
#     fi

#     if test "${_exclude_old_logs}" = true; then
#         "${_dir}"/start-sync-todays-logs.sh
#     fi
    
#     rm "${_lock_file}"
# }

# main "$@"
