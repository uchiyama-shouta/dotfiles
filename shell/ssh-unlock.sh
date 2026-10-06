# shellcheck shell=bash
set -euo pipefail

mode="${1:-manual}"
case "$mode" in
  manual|--auto|--gui) ;;
  *) echo 'usage: ssh-unlock [--auto|--gui]' >&2; exit 2 ;;
esac
if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
  echo 'ssh-unlock: XDG_RUNTIME_DIR is missing; start a systemd user session.' >&2
  exit 1
fi
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
key="$HOME/.ssh/id_ed25519_github"
if [[ ! -f "$key" || ! -f "$key.pub" ]]; then
  echo "ssh-unlock: install $key and $key.pub, then run ssh-unlock." >&2
  exit 1
fi

exec 9>"$XDG_RUNTIME_DIR/ssh-unlock.lock"
# Another login frontend owns the prompt; it will populate the shared agent.
flock -n 9 || exit 0
if ! systemctl --user start ssh-agent.service; then
  echo 'ssh-unlock: could not start the shared SSH agent.' >&2
  exit 1
fi
public_key=$(awk '{print $1 " " $2; exit}' "$key.pub")
set +e
identities=$(ssh-add -L 2>/dev/null)
agent_status=$?
set -e
if (( agent_status > 1 )); then
  echo 'ssh-unlock: cannot connect to the shared SSH agent.' >&2
  exit 1
fi
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/git"
mkdir -p "$state_dir"
umask 077
printf 'ninjin0604@gmail.com namespaces="git" %s\n' "$public_key" > "$state_dir/allowed_signers"
if awk '{print $1 " " $2}' <<< "$identities" | grep -Fxq "$public_key"; then
  exit 0
fi
if [[ "$mode" != manual ]]; then
  # One automatic attempt per agent lifetime, including cancellation.
  agent_pid=$(systemctl --user show ssh-agent.service --property=MainPID --value)
  marker="$XDG_RUNTIME_DIR/ssh-unlock-attempted"
  if [[ -f "$marker" && "$(cat "$marker")" == "$agent_pid" ]]; then
    exit 0
  fi
  printf '%s\n' "$agent_pid" > "$marker"
fi
if [[ "$mode" == --gui ]]; then
  export SSH_ASKPASS_REQUIRE=force
  # OpenSSH also expects DISPLAY for Wayland askpass frontends.
  export DISPLAY="${DISPLAY:-:0}"
elif [[ ! -t 0 ]]; then
  echo 'ssh-unlock: no terminal; run ssh-unlock interactively.' >&2
  exit 1
fi
if ! ssh-add "$key"; then
  echo 'ssh-unlock: unlocking failed or was cancelled; run ssh-unlock to retry.' >&2
  exit 1
fi
