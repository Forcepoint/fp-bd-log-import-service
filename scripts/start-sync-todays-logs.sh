#!/usr/bin/env bash
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -o errexit
set -o pipefail
set -o nounset

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"

main() {
    _aws_sync_dir="/forcepoint-logs/initial/pa"
    cd "${_aws_sync_dir}"

    # sync todays events
    _year="$(date +'%Y')"
    _month="$(date +'%m')"
    _day="$(date +'%d')"
    _aws_todays_sync_dir="${_year}/${_month}/${_day}"

    if [ -d "${_aws_sync_dir}/${_aws_todays_sync_dir}" ]; then
        rsync -avu --relative --delete "./${_aws_todays_sync_dir}" "/forcepoint-logs/pa/" 2> "${_dir}"/../logs/pa-sync-todays-errors.log
    fi
    
    # sync any yesterdays events that got missed around midnight
    _yesterday_year="$(date -d "yesterday" +'%Y')"
    _yesterday_month="$(date -d "yesterday" +'%m')"
    _yesterday_day="$(date -d "yesterday" +'%d')"
    _aws_yesterdays_sync_dir="${_yesterday_year}/${_yesterday_month}/${_yesterday_day}"
    _yesterdays_sync_dir="/forcepoint-logs/pa/${_yesterday_year}/${_yesterday_month}/${_yesterday_day}"

    if ([ -d "${_aws_sync_dir}/${_aws_yesterdays_sync_dir}" ] && [ -d "${_yesterdays_sync_dir}" ]); then
        rsync -avu --relative --delete "./${_aws_yesterdays_sync_dir}" "/forcepoint-logs/pa/" 2> "${_dir}"/pa-sync-todays-errors.log
    fi

}

main "$@"
