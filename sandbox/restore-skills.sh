#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ] || [ "${1:-}" = --help ]; then
  echo 'Usage: sandbox-restore-skills SANDBOX'
  [ "${1:-}" = --help ] && exit 0
  exit 2
fi

: "${SANDBOX_APM_FLAKE:?APM flake reference must be configured}"

# Check before modifying the sandbox-scoped policy.
sbx exec -w /home/agent/workspace/project "$1" sh -c '
  if [ ! -f apm.yml ] || [ ! -f apm.lock.yaml ]; then
    echo "Both apm.yml and apm.lock.yaml are required in the project root." >&2
    exit 1
  fi
'
echo 'Allowing pypi.io:443 and files.pythonhosted.org:443 for this sandbox.' >&2
sbx policy allow network --sandbox "$1" 'pypi.io:443,files.pythonhosted.org:443'

# Positional parameters are expanded by the shell inside the sandbox.
# shellcheck disable=SC2016
exec sbx exec -w /home/agent/workspace/project "$1" sh -c '
  set -eu
  export USER=agent
  . /home/agent/.nix-profile/etc/profile.d/nix.sh
  nix --extra-experimental-features "nix-command flakes" run "$1" -- install --frozen
  nix --extra-experimental-features "nix-command flakes" run "$1" -- audit --ci
' sh "$SANDBOX_APM_FLAKE"
