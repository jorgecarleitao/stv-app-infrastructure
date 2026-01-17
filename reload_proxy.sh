set -euo pipefail

podman cp Caddyfile proxy:/etc/caddy/Caddyfile
podman compose exec -w /etc/caddy proxy caddy reload
