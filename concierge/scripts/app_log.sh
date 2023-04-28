#!/bin/bash

set -e

PROJECTS_ROOT="/root/development"

app_name=$1

cd $PROJECTS_ROOT

# Load env file, in braces to prevent printing to log.
{
    set -o allexport
    source ".env/$app_name.env"
    set +o allexport
} 2>/dev/null

if [[ -d "$app_name" ]]; then
    docker compose -f "$app_name/docker-compose.yml" logs --no-log-prefix --tail 500
fi

exit 0
