#!/bin/sh
set -eu

if [ "$#" -lt 1 ]; then
  echo "Usage: nix-opencode.sh PROJECT_DIRECTORY [OPENCODE_ARGS...]" >&2
  exit 2
fi

project=$1
shift
cd "$project"
export USER=agent
export OPENCODE_ENABLE_EXA=1
# Child processes, including project scripts that invoke nix, need these features too.
export NIX_CONFIG="${NIX_CONFIG:+$NIX_CONFIG
}extra-experimental-features = nix-command flakes"
# Installed inside the sandbox by nix-dev-install.sh.
# shellcheck disable=SC1091
. /home/agent/.nix-profile/etc/profile.d/nix.sh
if [ "${1:-}" = run ]; then
  shift
  exec nix --extra-experimental-features 'nix-command flakes' develop --command opencode run --auto "$@"
fi
exec nix --extra-experimental-features 'nix-command flakes' develop --command opencode --auto "$@"
