#!/bin/bash
source /add_bash_util.sh

gh_install caddyserver/caddy linux_amd64.tar.gz /tmp/caddy.tar.gz
mkdir -p /tmp/caddy
tar -xzf /tmp/caddy.tar.gz -C /tmp/caddy


# Start the Node.js application
git clone https://github.com/waxz/Gemini-CLI-2-API.git /tmp/Gemini-CLI-2-API
cat << EOF | tee /tmp/Gemini-CLI-2-API/config.json
{
    "REQUIRED_API_KEY": "${REQUIRED_API_KEY:-}",
    "SERVER_PORT": 3000,
    "HOST": "localhost",
    "MODEL_PROVIDER": "gemini-cli-oauth",
    "OPENAI_API_KEY": "${OPENAI_API_KEY:-}",
    "OPENAI_BASE_URL": "https://api.openai.com/v1",
    "CLAUDE_API_KEY": "${CLAUDE_API_KEY:-}",
    "CLAUDE_BASE_URL": "https://api.anthropic.com/v1",
    "PROJECT_ID": "${PROJECT_ID:-}",
    "PROMPT_LOG_MODE": "console",
    "GEMINI_OAUTH_CREDS_FILE_PATH":"/tmp/gemini_oauth_creds.json"
}
EOF
cat << EOF | tee /tmp/gemini_oauth_creds.json
{
  "access_token": "${GEMINI_OAUTH_ACCESS_TOKEN:-}",
  "refresh_token": "${GEMINI_OAUTH_REFRESH_TOKEN:-}",
  "scope": "https://www.googleapis.com/auth/cloud-platform",
  "token_type": "Bearer",
  "expiry_date": 1753880406425
}
EOF
cd /tmp/Gemini-CLI-2-API && npm install && npm run start&
/tmp/caddy/caddy run --config /Caddyfile &
MAIN_PID=$!

# Wait for caddy process
wait $MAIN_PID

