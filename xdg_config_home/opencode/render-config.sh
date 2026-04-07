#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

out="${1:-opencode.json}"

if [[ -f ckpd.libsonnet ]]; then
  jsonnet -e "local base = import 'base.jsonnet'; local ckpd = import 'ckpd.libsonnet'; base { provider+: ckpd.provider }" > "$out"
else
  jsonnet base.jsonnet > "$out"
fi
