{ pkgs, self }:
let
  cfg = self.homeConfigurations.shota-ubuntu.config;
  tools =
    (import ../neovim/tools.nix {
      inherit pkgs;
      config = { };
    }).home.packages;
in
{
  neovim =
    pkgs.runCommand "dotfiles-neovim-smoke"
      {
        nativeBuildInputs = [
          cfg.programs.neovim.finalPackage
          pkgs.nodejs_22
          pkgs.git
          pkgs.rust-bin.stable.latest.default
        ]
        ++ tools;
      }
      ''
        export HOME=$TMPDIR/home
        export XDG_CONFIG_HOME=$HOME/.config
        export XDG_DATA_HOME=$HOME/.local/share
        export XDG_STATE_HOME=$HOME/.local/state
        export XDG_CACHE_HOME=$HOME/.cache
        mkdir -p $XDG_CONFIG_HOME
        ln -s ${cfg.xdg.configFile.nvim.source} $XDG_CONFIG_HOME/nvim
        export DOTFILES_TEST_DIR=$TMPDIR/fixtures
        mkdir -p "$DOTFILES_TEST_DIR"
        nvim --headless --cmd 'lua dofile("${./neovim-hooks.lua}")' \
          '+lua dofile("${./neovim-smoke.lua}")'
        touch $out
      '';
  shell-git =
    pkgs.runCommand "dotfiles-shell-git-smoke"
      {
        nativeBuildInputs = with pkgs; [
          bash
          zsh
          shellcheck
          git
          openssh
          coreutils
          gnugrep
          gawk
          util-linux
        ];
        SSH_UNLOCK = ../shell/ssh-unlock.sh;
        ZSH_CONFIG = ../shell/.zshrc;
        GIT_IGNORE = cfg.xdg.configFile."git/ignore".source;
        TEST_GIT_CONFIG = cfg.xdg.configFile."git/config".source;
      }
      ''
        bash ${./shell-git-smoke.sh}
        touch $out
      '';
  codex =
    pkgs.runCommand "dotfiles-codex-smoke"
      {
        nativeBuildInputs = [ pkgs.codex ];
      }
      ''
        export HOME=$TMPDIR/home
        mkdir -p "$HOME"
        codex --version > $out
        grep -Fx 'codex-cli ${pkgs.codex.version}' $out
      '';
}
