export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="$HOME/.moon/bin:$PATH"

eval "$(gh completion -s zsh)"
. $HOME/.asdf/asdf.sh
# . "$HOME/.cargo/env"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
