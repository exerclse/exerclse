#!/bin/sh
# Exerclse start script: API (Node) on 127.0.0.1:3000, nginx on Railway's $PORT.
set -e

# Rewrite the nginx listen port from Railway's PORT (default 8080 locally).
NGINX_PORT="${PORT:-8080}"
sed -i "s/listen 8080;/listen ${NGINX_PORT};/" /etc/nginx/nginx.conf

# Start the API in the background on its own fixed port.
PORT=3000 DATA_DIR="${DATA_DIR:-/data}" node /app/api/server.js &
API_PID=$!

# Give the API a moment to bind before nginx takes traffic.
sleep 2

# nginx in the foreground (container's main process).
exec nginx -g "daemon off;"
