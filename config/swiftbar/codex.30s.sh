#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v codex >/dev/null 2>&1; then
  echo "codex: missing"
  echo "---"
  echo "Install Codex CLI | href=https://github.com/openai/codex"
  exit 0
fi

json=$(codex doctor --json 2>/dev/null || echo "")
if [[ -z "$json" ]]; then
  echo "codex: error"
  exit 0
fi

version=$(echo "$json" | jq -r '.codexVersion')
model=$(grep '^model' ~/.codex/config.toml 2>/dev/null | head -1 | sed 's/^model = "//;s/"$//' || echo "?")

auth=~/.codex/auth.json
tok=$(jq -r '.tokens.access_token' "$auth" 2>/dev/null || echo "")
aid=$(jq -r '.tokens.account_id' "$auth" 2>/dev/null || echo "")

fmt_dur() {
  local s=$1
  local h=$(( s / 3600 ))
  local m=$(( (s % 3600) / 60 ))
  if (( h > 0 )); then
    echo "${h}h ${m}m"
  else
    echo "${m}m"
  fi
}

usage_json=""
if [[ -n "$tok" && -n "$aid" ]]; then
  usage_json=$(curl -sf -H "Authorization: Bearer $tok" -H "ChatGPT-Account-Id: $aid" "https://chatgpt.com/backend-api/wham/usage" 2>/dev/null || echo "")
fi

if [[ -z "$usage_json" ]]; then
  echo "codex: no usage"
  echo "---"
  echo "Version: ${version}"
  echo "Model: ${model}"
  exit 0
fi

pct5h=$(echo "$usage_json" | jq -r '.rate_limit.primary_window.used_percent')
pct7d=$(echo "$usage_json" | jq -r '.rate_limit.secondary_window.used_percent')
reset5h=$(echo "$usage_json" | jq -r '.rate_limit.primary_window.reset_after_seconds')
reset7d=$(echo "$usage_json" | jq -r '.rate_limit.secondary_window.reset_after_seconds')
reset_count=$(echo "$usage_json" | jq -r '.rate_limit_reset_credits.available_count // 0')

dur5=$(fmt_dur "$reset5h")
dur7=$(fmt_dur "$reset7d")

rem5=$((100 - pct5h))
rem7=$((100 - pct7d))
echo "codex: 5h:${rem5}%, 7d:${rem7}%"
echo "---"
echo "Version: ${version}"
echo "Model: ${model}"
echo "---"
echo "5h Remaining: ${rem5}% (resets in ${dur5})"
echo "7d Remaining: ${rem7}% (resets in ${dur7})"
echo "---"
echo "Reset available: ${reset_count}"
echo "Open Codex | bash=open param1=-a param2=Codex"
