set -e

PROJECTS_ROOT="/root/development"

app_name=$1

cd $PROJECTS_ROOT

if [[ -d "$app_name" ]]; then
    docker compose -f "$app_name/docker-compose.yml" logs --no-log-prefix --tail 100
fi

exit 0