#!/bin/bash
source /add_bash_util.sh

gh_install caddyserver/caddy linux_amd64.tar.gz /tmp/caddy.tar.gz
mkdir -p /tmp/caddy
tar -xzf /tmp/caddy.tar.gz -C /tmp/caddy

cat << EOF | tee /tmp/Caddyfile 
proxy /ai localhost:3000
proxy /auth localhost:8085
EOF
cat << EOF | tee /tmp/config.json
${CONFIG}
EOF
# Start the Node.js application
git clone https://github.com/waxz/Gemini-CLI-2-API.git /tmp/Gemini-CLI-2-API
cd /tmp/Gemini-CLI-2-API && npm install && npm run start
# /tmp/caddy/caddy run --config /tmp/Caddyfile &

