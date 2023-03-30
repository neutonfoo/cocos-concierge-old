set -ex

PROJECTS_ROOT="/root/development"

app_name=$1
rebuild=$2

cd $PROJECTS_ROOT

if [[ -d "$app_name" ]]; then
    docker compose -f "$app_name/docker-compose.yml" down

    if [[ $rebuild -eq "1" ]]; then
        docker compose -f "$app_name/docker-compose.yml" up -d --build
    else
        docker compose -f "$app_name/docker-compose.yml" up -d
    fi
fi

exit 0