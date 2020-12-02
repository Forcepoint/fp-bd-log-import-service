#!/usr/bin/env bash

readonly _dir="$(cd "$(dirname "${0}")" && pwd)"
readonly _home_folder="$(cd "${_dir}/.." && pwd)"

install_prerequisite_centos() {
    echo "install_prerequisite_centos"
    sudo yum update -y
    sudo yum install -y curl unzip rsync
}

install_prerequisite_debian() {
    echo "install_prerequisite_debian"
    sudo apt update && sudo apt install -y curl rsync unzip
    sleep 5
}

main() {
    hostnamectl | grep -qi centos && install_prerequisite_centos || install_prerequisite_debian
    cd "$_dir"
    rm -rf ./aws 2> /dev/null
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip ./awscliv2.zip
    sudo chmod +x ./*.sh ../*.sh ../scripts/*.sh
    sudo ./aws/install
    rm -rf ./awscliv2.zip 2> /dev/null
}

main "$@"
