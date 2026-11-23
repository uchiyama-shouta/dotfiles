#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ] || [ "${1:-}" = --help ]; then
  echo 'Usage: sandbox-bundle SANDBOX BRANCH OUTPUT_DIRECTORY'
  echo 'OUTPUT_DIRECTORY must not already exist.'
  [ "${1:-}" = --help ] && exit 0
  exit 2
fi

sandbox=$1
branch=$2
output=$3
umask 077

# A new directory avoids overwriting a previous export or following a destination symlink.
mkdir -- "$output"
output=$(cd -- "$output" && pwd -P)
token_file=$(mktemp "$output/.bundle-XXXXXXXXXXXX")
suffix=${token_file##*/}
rm -- "$token_file"
remote_bundle="/tmp/sandbox-result-$suffix.bundle"

# Reserve the remote name without overwriting an existing file.
# Positional parameters are expanded by the shell inside the sandbox.
# shellcheck disable=SC2016
sbx exec "$sandbox" sh -c '
  set -eu
  umask 077
  set -C
  : > "$1"
  set +C
  cd /home/agent/workspace/project
  git check-ref-format --branch "$2" >/dev/null
  git show-ref --verify --quiet "refs/heads/$2"
  git bundle create "$1" "refs/heads/$2"
' sh "$remote_bundle" "$branch"

sbx cp "$sandbox:$remote_bundle" "$output/result.bundle"
echo "Bundle copied to $output/result.bundle"
echo "Temporary Sandbox bundle retained at $remote_bundle"
