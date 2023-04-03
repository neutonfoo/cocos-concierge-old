#!/bin/bash

set -ex

PROJECTS_ROOT="/root/development"

app_name=$1
action=$2

cd $PROJECTS_ROOT

# Load env file, in braces to prevent printing to log.
{
    set -o allexport
    source ".env/$app_name.env"
    set +o allexport
} 2>/dev/null

if [[ -d "$app_name" ]]; then
    docker compose -f "$app_name/docker-compose.yml" down

    if [[ $action -eq "0" ]]; then
        docker compose -f "$app_name/docker-compose.yml" up -d
    elif [[ $action -eq "1" ]]; then
        docker compose -f "$app_name/docker-compose.yml" up -d --build
    fi
fi

exit 0
