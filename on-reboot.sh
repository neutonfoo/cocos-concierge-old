#!/bin/bash

set -x

PROJECTS_ROOT="/root/development"

cd "$PROJECTS_ROOT/cocos-concierge"
docker compose down

# Reboot concierge
cd concierge
source env/bin/activate
nohup python app.py >/dev/null 2>&1 &
deactivate
cd ../

# Start reverse proxy + certbot
docker compose up -d

# Start all services and daemons
PROJECTS_JSON=$(cat "projects.json")

# Collect the keys (= folder names)
SERVICES=$(echo $PROJECTS_JSON | jq -r '.services|keys[]')
DAEMONS=$(echo $PROJECTS_JSON | jq -r '.daemons|keys[]')

cd $PROJECTS_ROOT

for daemon in $DAEMONS; do
    docker compose -f "$daemon/docker-compose.yml" up -d --remove-orphans
done

for service in $SERVICES; do
    docker compose -f "$service/docker-compose.yml" up -d --remove-orphans
done
