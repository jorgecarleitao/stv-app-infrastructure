set -euo pipefail

docker cp Caddyfile proxy:/etc/caddy/Caddyfile
docker compose exec -w /etc/caddy proxy caddy reload
