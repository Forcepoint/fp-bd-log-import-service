#!/usr/bin/env bash

main() {
    while true; do
        systemctl is-active fp-csg-aws-log-service.service | grep -qw "^active$" || systemctl restart fp-csg-aws-log-service.service
        sleep 600
    done
}

main "$@"
