#!/bin/bash

set -x

app_type=$1
service_name=$2
service_repository="../../$2"

github_repository=$3

echo $app_type $service_name $repository

if [ -d $service_repository ]; then
    rm -rf $service_repository
fi

git clone --depth 1 --branch main "git@github.com:$github_repository.git" "$service_repository"
cd $service_repository
docker compose up -d --build

exit 0

# TODO: Write code that will
# 1 - Check to see that the service exists (in the json)
# 2 - docker compose down the current service (if running)
# 3 - Delete the folder (if exists)
# 4 - Reclone the folder
# 5 - docker compose up

# repo_folder_name=$(echo $repository | sed -r 's/\//_/g')