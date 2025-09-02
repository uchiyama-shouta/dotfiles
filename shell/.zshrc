local now=$(date +"%s")
local updated=$(date -r ~/.zcompdump +"%s")
local threshold=$((60 * 60 * 24))

if [ $((${now} - ${updated})) -gt ${threshold} ]; then
  compinit
else
  # if there are new functions can be omitted by giving the option -C.
  compinit -C
fi

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

# if (which zprof > /dev/null) ;then
#     zprof | less
# fi
