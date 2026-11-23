#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: sandbox-create [--clone-only] SANDBOX_NAME [OWNER/REPOSITORY]" >&2
}

clone_only=false
if [ "${1:-}" = --clone-only ]; then
  clone_only=true
  shift
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ] || { "$clone_only" && [ "$#" -ne 2 ]; }; then
  usage
  exit 2
fi

sandbox=$1
repo=${2:-}
if [ -n "$repo" ] && { ! [[ "$repo" =~ ^[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+$ ]] || [ "${repo#*/}" = . ] || [ "${repo#*/}" = .. ]; }; then
  echo "Repository must be in GitHub OWNER/REPOSITORY form." >&2
  exit 2
fi

if ! "$clone_only"; then
  if [ "$(sbx settings get ssh.agentForwardingEnabled)" != false ]; then
    echo "SSH Agent forwarding must be disabled before creating a sandbox." >&2
    exit 1
  fi

  if ! sbx policy ls --json --type network --decision deny | jq -e '
    any(.rules[]; .id == "default-deny-all" and .scope == "global" and .status == "active")
  ' >/dev/null; then
    echo "The global deny-all network policy is not active." >&2
    exit 1
  fi

  kit_dir=$(mktemp -d)
  trap 'rm -rf -- "$kit_dir"' EXIT
  cp -RL "${XDG_CONFIG_HOME:-$HOME/.config}/sbx/nix-kit/." "$kit_dir/"
  sbx create --name "$sandbox" --skills off --kit "$kit_dir" opencode
fi

if [ -n "$repo" ]; then
  # The positional parameter is expanded by the shell inside the sandbox.
  # shellcheck disable=SC2016
  if ! sbx exec "$sandbox" sh -c '
    cd /home/agent/workspace
    git -c credential.helper="!gh auth git-credential" clone -- "https://github.com/$1.git" project
  ' sh "$repo"; then
    echo "Clone failed. Sandbox '$sandbox' may already exist; check /home/agent/workspace/project before retrying." >&2
    echo "Retry: sandbox-create --clone-only $sandbox $repo" >&2
    exit 1
  fi
  echo "Cloned to $sandbox:/home/agent/workspace/project"
fi
