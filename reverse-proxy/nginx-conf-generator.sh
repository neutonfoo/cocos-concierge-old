#!/bin/bash

# IMPORTANT
# This file is run from the main reposity directory (not this one)
# -- All URLs are relative to the repository directory (parent of this folder)

if [ $(basename $PWD) != "cocos-concierge" ]; then
	echo "Current directory = $PWD"
	echo "Please run this file from the main repository directory."
	exit 1
fi

PARENT_DIR="reverse-proxy"

# Services config is a string array that contains the nginx.conf locations for services
declare -a services_config=()

# Load project.json into a variable
PROJECTS_JSON=$(cat "projects.json")

# Collect the keys and load the services/daemon jsons themselves
SERVICES_JSON=$(echo $PROJECTS_JSON | jq -r '.services')
SERVICES=$(echo $PROJECTS_JSON | jq -r '.services|keys[]')

DAEMONS_JSON=$(echo $PROJECTS_JSON | jq -r '.daemons')
DAEMONS=$(echo $PROJECTS_JSON | jq -r '.daemons|keys[]')

# Loop through services
for service_name in $SERVICES; do
	# repository=$(echo $SERVICES_JSON | jq -r ".[\"$service_name\"]")

	# Replace the / with an underscore
	# repo_folder_name=$(echo $repository | sed -r 's/\//_/g')

	# If the repository folder doesn't currently exist, clone it
	# if [ ! -d ../"$repo_folder_name" ]; then
	# 	git clone --depth 1 --branch main git@github.com:$repository.git ../"$repo_folder_name"
	# fi

	# Since it's a service, add to nginx.conf to enable routing
	services_config+=(
		"location ~ ^\/$service_name\/?(.*)$
		{
			set \$target http://$service_name;
			rewrite ^\/$service_name\/?(.*)$ /\$1 break;
			proxy_pass \$target;
		}"
	)
done

# for daemon_name in $DAEMONS; do
# 	repository=$(echo $DAEMONS_JSON | jq -r ".$daemon_name")
# 	echo $repository
# done

cat << EOF > ./"$PARENT_DIR"/nginx.conf
worker_processes 1;

events
{
	worker_connections 1024;
}

http
{
	server
	{
		listen 80;
		listen [::]:80;
		server_name cocoshouse.xyz;

		location /.well-known/acme-challenge/ {
			root /var/www/certbot;
		}

		location / {
			return 301 https://\$host\$request_uri;
		}
	}

	server
	{
		listen 443 ssl;
		listen [::]:443 ssl;
		server_name cocoshouse.xyz;

		ssl_certificate /etc/letsencrypt/live/cocoshouse.xyz/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/cocoshouse.xyz/privkey.pem;
		include /etc/letsencrypt/options-ssl-nginx.conf;
		ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

		proxy_buffering off;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-Host \$host;
		proxy_set_header X-Forwarded-Port \$server_port;

		resolver 127.0.0.11 valid=30s;

		${services_config[@]}
	}
}
EOF
