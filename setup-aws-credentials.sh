#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"

readonly _BOLD_WHITE='\033[1;37m'
readonly _NO_COLOR='\033[0m'
readonly _BOLD_RED='\033[1;31m'

error() {
  local -r __msg="${1}"
  printf "${_BOLD_RED}[Error] ${__msg}${_NO_COLOR}\n"
}

validate_prerequisites() {
  local __r=0
  local __prerequisites=("$@")
  local __clear_previous_display="\r\033[K"
  for prerequisite in "${__prerequisites[@]}"; do
    echo -en "${__clear_previous_display}Prerequisite - ${prerequisite} - check" && sleep 0.1
    command -v ${prerequisite} >/dev/null 2>&1 || {
      error "${__clear_previous_display}We require >>> ${prerequisite} <<< but it's not installed. Please try again after installing ${prerequisite}." &&
        __r=1 &&
        break
    }
  done
  echo -en "${__clear_previous_display}"
  return "${__r}"
}

info() {
    local -r __msg="${1}"
    local -r __nobreakline="${2:-""}"
    test ! -z "${__nobreakline}" &&
        printf "${_BOLD_WHITE}${__msg}${_NO_COLOR}" ||
        printf "${_BOLD_WHITE}${__msg}${_NO_COLOR}\n"
}

setup_aws_credentials() {
    local -r __config_file="${1}"

    PS3='Please enter your choice: '
    options=("Setup Private Access Account" "Setup Cloud Security Gateway Account" "Setup Both Accounts" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Setup Private Access Account")
                  cat /dev/null > "${__config_file}"
                  info "Enter AWS Access Key ID: " "nobreakline"
                  read __user_input_1
                  info "Enter AWS Secret Access Key: " "nobreakline"
                  read __user_input_2
                  cat <<EOF >>"${__config_file}"
[pa]
aws_access_key_id = ${__user_input_1}
aws_secret_access_key = ${__user_input_2}
EOF
                break
                ;;
            "Setup Cloud Security Gateway Account")
                cat /dev/null > "${__config_file}"
                info "Enter AWS Access Key ID: " "nobreakline"
                read __user_input_1
                info "Enter AWS Secret Access Key: " "nobreakline"
                read __user_input_2
                cat <<EOF >>"${__config_file}"
[csg]
aws_access_key_id = ${__user_input_1}
aws_secret_access_key = ${__user_input_2}
EOF
                break
                ;;
            "Setup Both Accounts")
                cat /dev/null > "${__config_file}"
                info "Enter AWS Access Key ID (Private Access Account): " "nobreakline"
                read __user_input_1
                info "Enter AWS Secret Access Key (Private Access Account): " "nobreakline"
                read __user_input_2
                cat <<EOF >>"${__config_file}"
[pa]
aws_access_key_id = ${__user_input_1}
aws_secret_access_key = ${__user_input_2}
EOF
                info "Enter AWS Access Key ID (Cloud Security Gateway Account): " "nobreakline"
                read __user_input_1
                info "Enter AWS Secret Access Key (Cloud Security Gateway Account): " "nobreakline"
                read __user_input_2
                cat <<EOF >>"${__config_file}"
[csg]
aws_access_key_id = ${__user_input_1}
aws_secret_access_key = ${__user_input_2}
EOF
                break
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

    chmod 600 "${__config_file}"

    return $?
}

main() {
    local __prerequisites=(printf)
    validate_prerequisites "${__prerequisites[@]}"
    mkdir -p "${_dir}"/.aws
    setup_aws_credentials "${_dir}"/.aws/credentials
}

main "$@"
