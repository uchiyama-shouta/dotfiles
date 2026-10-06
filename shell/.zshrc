if [[ -d "$HOME/.moon/bin" ]]; then
  path=("$HOME/.moon/bin" $path)
fi

# GUI logins unlock through askpass; terminal-only sessions use their TTY.
if [[ -t 0 ]]; then
  ssh-unlock --auto || true
fi

function dcex() {
  if (( $# == 0 )); then
    print -u2 'usage: dcex SERVICE [COMMAND [ARG...]]'
    return 2
  fi
  local service="$1"
  shift
  if (( $# == 0 )); then
    docker compose exec "$service" sh
  else
    docker compose exec "$service" "$@"
  fi
}

function dcpurge() {
  local answer
  read -r "answer?Delete this project's Docker volumes and images? [y/N] "
  if [[ "$answer" == [yY] ]]; then
    docker compose down --rmi all --volumes --remove-orphans
  fi
}
