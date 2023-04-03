#!/bin/bash
set -x

cd /root/development

# Kill the previous Updater nohup service
kill -9 $(pgrep python)

# Stop and remove repo if it exists
if [[ -d "cocos-concierge" ]]; then
    cd cocos-concierge
    docker compose down
    cd ../
    rm -rf cocos-concierge
fi
git clone --depth 1 --branch main git@github.com:neutonfoo/cocos-concierge.git
cd cocos-concierge

# Start the Updater service
cd concierge
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
nohup python app.py &>logs/concierge.app.txt &
cd ../

# Start reverse-proxy and certbot
./reverse-proxy/nginx-conf-generator.sh
docker compose up -d --build --force-recreate

# Collect the keys and load the services/daemon jsons themselves
SERVICES_JSON=$(echo $PROJECTS_JSON | jq -r '.services')
SERVICES=$(echo $PROJECTS_JSON | jq -r '.services|keys[]')

DAEMONS_JSON=$(echo $PROJECTS_JSON | jq -r '.daemons')
DAEMONS=$(echo $PROJECTS_JSON | jq -r '.daemons|keys[]')
