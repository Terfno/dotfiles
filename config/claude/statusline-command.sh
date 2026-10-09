#!/bin/bash
# Claude Code statusLine
# モデル名 / ディレクトリ / git ブランチ / usage(5h・7d) を表示する

input=$(cat)

esc=$'\033'

model=$(echo "$input" | jq -r '.model.display_name')
dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$dir")

git_info=""
if git -C "$dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ -n "$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      dirty="*"
    else
      dirty=""
    fi
    git_info=" ${esc}[2m(${branch}${dirty})${esc}[0m"
  fi
fi

# usage: Pro/Max のみ、初回 API レスポンス後に現れる。各窓は独立して不在の可能性あり
usage_info=""
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
usage_parts=""
[ -n "$five_h" ] && usage_parts="5h $(printf '%.0f' "$five_h")%"
[ -n "$week" ] && usage_parts="${usage_parts:+$usage_parts }7d $(printf '%.0f' "$week")%"
[ -n "$usage_parts" ] && usage_info=" ${esc}[2m[${usage_parts}]${esc}[0m"

printf "${esc}[2m%s${esc}[0m ${esc}[2m%s${esc}[0m%s%s\n" "$model" "$dir_name" "$git_info" "$usage_info"
