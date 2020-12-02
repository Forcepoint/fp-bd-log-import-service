#!/usr/bin/env bash
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -o pipefail
set -o nounset

main() {
    
    _year="$(date +'%Y')"
    _month="$(date +'%m')"
    _day="$(date +'%d')"

    # clean up
    find /forcepoint-logs/pa -mindepth 1 ! -regex "^/forcepoint-logs/pa/${_year}\(/.*\)?" -delete 2> /dev/null
    find /forcepoint-logs/pa/${_year} -mindepth 1 ! -regex "^/forcepoint-logs/pa/${_year}/${_month}\(/.*\)?" -delete 2> /dev/null
    find /forcepoint-logs/pa/${_year}/${_month} -mindepth 1 ! -regex "^/forcepoint-logs/pa/${_year}/${_month}/${_day}\(/.*\)?" -delete 2> /dev/null
    echo "done"
}

main "$@"
