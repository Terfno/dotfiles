#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v codex >/dev/null 2>&1; then
  echo ":warning: codex not found"
  echo "---"
  echo "Install Codex CLI | href=https://github.com/openai/codex"
  exit 0
fi

json=$(codex doctor --json 2>/dev/null || echo "")

if [[ -z "$json" ]]; then
  echo ":warning: codex error"
  exit 0
fi

overall=$(echo "$json" | jq -r '.overallStatus')
version=$(echo "$json" | jq -r '.codexVersion')
model=$(grep '^model' ~/.codex/config.toml 2>/dev/null | head -1 | sed 's/^model = "//;s/"$//' || echo "?")

case "$overall" in
  ok)
    icon=":white_check_mark:"
    color="green"
    ;;
  warning)
    icon=":warning:"
    color="orange"
    ;;
  error)
    icon=":x:"
    color="red"
    ;;
  *)
    icon=":grey_question:"
    color="gray"
    ;;
esac

auth_status=$(echo "$json" | jq -r '.checks["auth.credentials"].status // "?"')
app_server_status=$(echo "$json" | jq -r '.checks["app_server.status"].status // "?"')
updates_status=$(echo "$json" | jq -r '.checks["updates.status"].status // "?"')

echo "Codex ${version} | color=${color}"
echo "---"
echo "Version: ${version}"
echo "Overall: ${overall} | color=${color}"
echo "Model: ${model:-unknown}"
echo "---"
echo "Auth: ${auth_status}"
echo "App Server: ${app_server_status}"
echo "Updates: ${updates_status}"
echo "---"
echo "Open Codex | bash=open param1=-a param2=Codex"
echo "Run Doctor | bash=/opt/homebrew/bin/codex param1=doctor terminal=true"
