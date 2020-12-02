#!/usr/bin/env bash

set -o pipefail
set -o nounset

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"

main() {
    for _sysd_file in "${_dir}"/*.service; do
        systemctl status "$(basename "${_sysd_file}")"
    done
    for _sysd_timer_file in "${_dir}"/*.timer; do
        systemctl status "$(basename "${_sysd_timer_file}")"
    done
}

main "$@"
