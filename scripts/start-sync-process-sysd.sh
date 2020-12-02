#!/usr/bin/env bash
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -o errexit
set -o pipefail
set -o nounset

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"

source "${_dir}"/sync-process-util.sh

main() {
    start-sync-process "$@"
}

main "$@"

