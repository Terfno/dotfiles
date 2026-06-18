#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v ollama >/dev/null 2>&1; then
  echo "Error: ollama is not installed" >&2
  exit 1
fi

output="ollama.libsonnet"

{
  echo '{'
  echo '  models: {'

  while IFS= read -r name; do
    [ -z "$name" ] && continue

    tool_call=true
    reasoning=false

    case "$name" in
      *deepseek-r1*|*deepseek/r1*|*qwq*|*:thinking*|*reasoning-*)
        reasoning=true
        ;;
    esac

    echo "    '${name}': {"
    echo "      name: '${name}',"
    echo "      tool_call: ${tool_call},"
    echo "      reasoning: ${reasoning},"
    echo "    },"
  done < <(ollama list | tail -n +2 | awk '{print $1}')

  echo '  },'
  echo '}'
} > "$output"

echo "Generated $output"
./render-config.sh
