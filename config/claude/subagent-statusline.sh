#!/bin/bash
# Claude Code subagentStatusLine
# subagent 行に description とモデル名を表示する
# model 未解決のタスクは出力しない（デフォルト表示のまま）

input=$(cat)

esc=$'\033'

echo "$input" | jq -c '.tasks[] | select(.model != null)' | while read -r task; do
  id=$(echo "$task" | jq -r '.id')
  desc=$(echo "$task" | jq -r '.description // .name // ""')
  # "claude-" prefix と日付サフィックスは冗長なので落とす
  model=$(echo "$task" | jq -r '.model' | sed -e 's/^claude-//' -e 's/-[0-9]\{8\}$//')
  content="${desc} ${esc}[2m[${model}]${esc}[0m"
  jq -cn --arg id "$id" --arg content "$content" '{id: $id, content: $content}'
done
