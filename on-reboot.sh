#!/bin/bash

set -x

PROJECTS_ROOT="/root/development"

cd "$PROJECTS_ROOT/cocos-concierge"
docker compose down

# Reboot concierge

# Stop any previous coco's concierge
kill -9 $(pgrep python)

cd concierge
source env/bin/activate
nohup python app.py >/dev/null 2>&1 &
deactivate

cd "$PROJECTS_ROOT/cocos-concierge"

# Start reverse proxy + certbot
reverse-proxy/nginx-conf-generator.sh
docker compose up -d --build --force-recreate

# Start all services and daemons
PROJECTS_JSON=$(cat "projects.json")

# Collect the keys (= folder names)
SERVICES=$(echo $PROJECTS_JSON | jq -r '.services|keys[]')
DAEMONS=$(echo $PROJECTS_JSON | jq -r '.daemons|keys[]')

cd $PROJECTS_ROOT

for daemon in $DAEMONS; do
    cocos-concierge/concierge/scripts/restart.sh $daemon
done

for service in $SERVICES; do
    cocos-concierge/concierge/scripts/restart.sh $service
done
