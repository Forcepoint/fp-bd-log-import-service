#!/usr/bin/env bash

main() {
    while true; do
        systemctl is-active fp-pa-aws-log-service.service | grep -qw "^active$" || systemctl restart fp-pa-aws-log-service.service
        sleep 600
    done
}

main "$@"
