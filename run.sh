#!/bin/bash
source /add_bash_util.sh

gh_install caddyserver/caddy linux_amd64.tar.gz /tmp/caddy.tar.gz
mkdir -p /tmp/caddy
tar -xzf /tmp/caddy.tar.gz -C /tmp/caddy


# Start the Node.js application
git clone https://github.com/waxz/Gemini-CLI-2-API.git /tmp/Gemini-CLI-2-API
cat << EOF | tee /tmp/Gemini-CLI-2-API/config.json
${CONFIG}
EOF

cd /tmp/Gemini-CLI-2-API && npm install && npm run start&
/tmp/caddy/caddy run --config /Caddyfile &
MAIN_PID=$!

# Wait for caddy process
wait $MAIN_PID

