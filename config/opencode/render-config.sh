#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

out="${1:-opencode.json}"

if command -v brew >/dev/null 2>&1; then
  echo "homebrew is ready";
  brew -v
else
  echo "installing homebrew";
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
fi

brew install jsonnet

if [[ -f ckpd.libsonnet ]]; then
  jsonnet -e "local base = import 'base.jsonnet'; local ckpd = import 'ckpd.libsonnet'; base { provider+: ckpd.provider }" > "$out"
else
  jsonnet base.jsonnet > "$out"
fi

echo "$out is rendered"
