#!/usr/bin/env bash
set -euo pipefail
export HOME="$TMPDIR/home"
export XDG_RUNTIME_DIR="$TMPDIR/runtime"
export XDG_STATE_HOME="$HOME/.local/state"
export GIT_CONFIG_GLOBAL="$TEST_GIT_CONFIG"
export GIT_CONFIG_NOSYSTEM=1
mkdir -p "$HOME/.ssh" "$XDG_RUNTIME_DIR" "$TMPDIR/bin"
shellcheck -s bash "$SSH_UNLOCK"
zsh -n "$ZSH_CONFIG"

cat > "$TMPDIR/bin/systemctl" <<'SH'
#!/usr/bin/env bash
if [[ "$*" == *--property=MainPID* ]]; then echo "$TEST_AGENT_PID"; fi
SH
cat > "$TMPDIR/bin/askpass" <<'SH'
#!/usr/bin/env bash
echo attempt >> "$TMPDIR/prompts"
if [[ "${CANCEL_UNLOCK:-0}" == 1 ]]; then exit 1; fi
sleep 0.2
printf '%s\n' 'test-only-passphrase'
SH
cat > "$TMPDIR/bin/docker" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$TMPDIR/docker-args"
SH
chmod +x "$TMPDIR/bin/"*
for stub in "$TMPDIR/bin/"*; do
  sed -i "1c#!$(command -v bash)" "$stub"
done
export PATH="$TMPDIR/bin:$PATH"
export SSH_ASKPASS="$TMPDIR/bin/askpass"
export SSH_ASKPASS_REQUIRE=force
ssh-keygen -q -t ed25519 -N test-only-passphrase -f "$HOME/.ssh/id_ed25519_github"
ssh-agent -D -a "$XDG_RUNTIME_DIR/ssh-agent" > "$TMPDIR/agent.log" 2>&1 &
export TEST_AGENT_PID=$!
trap 'kill "$TEST_AGENT_PID" 2>/dev/null || true' EXIT
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
for _ in {1..50}; do
  [[ -S "$SSH_AUTH_SOCK" ]] && break
  sleep 0.02
done
bash "$SSH_UNLOCK" --gui &
first=$!
bash "$SSH_UNLOCK" --gui &
second=$!
wait "$first"
wait "$second"
[[ $(wc -l < "$TMPDIR/prompts") == 1 ]]
bash "$SSH_UNLOCK" --auto
[[ $(wc -l < "$TMPDIR/prompts") == 1 ]]
ssh-add -l > /dev/null

mkdir -p "$TMPDIR/repo"
cd "$TMPDIR/repo"
git init -q
git config user.signingkey "$HOME/.ssh/id_ed25519_github.pub"
git config gpg.ssh.allowedSignersFile "$XDG_STATE_HOME/git/allowed_signers"
git config core.excludesFile "$GIT_IGNORE"
for file in Cargo.lock flake.lock pnpm-lock.yaml .env.example .env.sample .env.template; do
  if git check-ignore -q "$file"; then echo "Unexpectedly ignored: $file" >&2; exit 1; fi
done
git check-ignore -q .env
git check-ignore -q .env.production
echo example > example.txt
git add example.txt
git commit -qm 'test signing'
git tag -m 'signed test' signed-tag
git verify-commit HEAD
git verify-tag signed-tag
[[ $(wc -l < "$TMPDIR/prompts") == 1 ]]
git init --bare -q "$TMPDIR/remote.git"
git remote add origin "$TMPDIR/remote.git"
git push -q origin HEAD
git tag -a -m local-only local-only
git fetch -q origin
git show-ref --verify --quiet refs/tags/local-only

# Cancellation is remembered by automatic entrypoints; explicit retry works.
ssh-add -D > /dev/null 2>&1
rm "$XDG_RUNTIME_DIR/ssh-unlock-attempted"
if CANCEL_UNLOCK=1 bash "$SSH_UNLOCK" --gui; then echo 'Cancellation unexpectedly succeeded' >&2; exit 1; fi
count=$(wc -l < "$TMPDIR/prompts")
bash "$SSH_UNLOCK" --auto
[[ $(wc -l < "$TMPDIR/prompts") == "$count" ]]
script -q -e -c "bash '$SSH_UNLOCK' manual" /dev/null > /dev/null
ssh-add -l > /dev/null
mv "$HOME/.ssh/id_ed25519_github" "$HOME/.ssh/missing-key"
if bash "$SSH_UNLOCK" --gui; then echo 'Missing key unexpectedly succeeded' >&2; exit 1; fi

# Argument boundaries survive spaces; dcdown never deletes volumes/images.
zsh -f -c 'source "$ZSH_CONFIG"; dcex "web service" printf "%s" "hello world"'
printf '%s\n' compose exec 'web service' printf '%s' 'hello world' > "$TMPDIR/expected-args"
cmp "$TMPDIR/expected-args" "$TMPDIR/docker-args"
zsh -f -c 'source "$ZSH_CONFIG"; dcex web'
printf '%s\n' compose exec web sh > "$TMPDIR/expected-args"
cmp "$TMPDIR/expected-args" "$TMPDIR/docker-args"
if zsh -f -c 'source "$ZSH_CONFIG"; dcex'; then exit 1; fi
if grep -E 'dcdown.*(--volumes|--rmi)' "$ZSH_CONFIG"; then exit 1; fi
echo 'Shell and Git smoke checks passed'
