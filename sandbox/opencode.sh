#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "${1:-}" = --help ]; then
  echo 'Usage: sandbox-opencode SANDBOX [OPENCODE_ARGS...]'
  echo 'Example: sandbox-opencode my-sandbox run --model MODEL "Task"'
  [ "$#" -gt 0 ] && exit 0
  exit 2
fi

sandbox=$1
shift
exec_args=()
if [ -t 0 ] && [ -t 1 ]; then
  exec_args=(-it)
fi

exec sbx exec "${exec_args[@]}" "$sandbox" sh /home/agent/nix-opencode.sh /home/agent/workspace/project "$@"
