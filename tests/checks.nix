{ pkgs, self }:
let
  cfg = self.homeConfigurations.shouta-wsl.config;
  codexMutableActivation = pkgs.writeShellScript "dotfiles-codex-activation" ''
    set -euo pipefail
    ${cfg.lib.bash.initHomeManagerLib}
    ${pkgs.lib.replaceStrings [ cfg.home.homeDirectory ] [ "@TEST_HOME@" ]
      cfg.home.activation.codexMutableSettings.data
    }
  '';
  hostConfigs = builtins.mapAttrs (_: host: host.config) self.homeConfigurations // {
    shota-nixos = self.nixosConfigurations.shota-nixos.config.home-manager.users.shota;
  };
  requiredTools = with pkgs; [
    codex
    opencode
    htop
    git
    gh
    zsh
    docker-client
    docker-compose
  ];
  hostToolsPresent = pkgs.lib.all (
    host:
    let
      config = hostConfigs.${host};
    in
    pkgs.lib.assertMsg (pkgs.lib.all (
      tool: pkgs.lib.any (installed: toString installed == toString tool) config.home.packages
    ) requiredTools) "${host}: a required development tool is missing from home.packages"
  ) (builtins.attrNames hostConfigs);
  tools =
    (import ../neovim/tools.nix {
      inherit pkgs;
      config = { };
    }).home.packages;
in
{
  host-tools =
    assert hostToolsPresent;
    pkgs.runCommand "dotfiles-host-tools" { } ''
      touch $out
    '';
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
  opencode =
    pkgs.runCommand "dotfiles-opencode-smoke"
      {
        nativeBuildInputs = [ pkgs.opencode ];
      }
      ''
        export HOME=$TMPDIR/home
        mkdir -p "$HOME"
        opencode --version > $out
        grep -Fx "opencode v${pkgs.opencode.version}" $out
      '';
  opencode-permissions =
    let
      file = cfg.xdg.configFile."opencode/home-manager.json".source;
    in
    assert pkgs.lib.assertMsg
      (pkgs.lib.hasSuffix "opencode/home-manager.json" cfg.home.sessionVariables.OPENCODE_CONFIG)
      "OpenCode mutable settings must be wired through OPENCODE_CONFIG";
    pkgs.runCommand "dotfiles-opencode-permission-policy"
      {
        nativeBuildInputs = [ pkgs.jaq ];
      }
      ''
        jaq -e 'keys == ["$schema", "permission"]' ${file}
        jaq -e '
          .permission.edit == "allow"
          and .permission.external_directory == "ask"
          and .permission.webfetch == "ask"
          and .permission.read["*"] == "allow"
          and .permission.read["*.env"] == "ask"
          and .permission.read["*.env.*"] == "ask"
          and .permission.read["*.env.example"] == "allow"
        ' ${file}
        jaq -e '
          .permission.bash["*"] == "ask"
          and .permission.bash["home-manager switch*"] == "deny"
          and .permission.bash["nixos-rebuild switch*"] == "deny"
          and .permission.bash["sudo*"] == "deny"
        ' ${file}
        jaq -e '(.permission.bash | keys[0] == "*" and (keys | length) == 4)' ${file}
        jaq -e '(.permission.read | keys[0] == "*" and (keys | length) == 4)' ${file}
        touch $out
      '';
  codex-settings =
    pkgs.runCommand "dotfiles-codex-mutable-settings"
      {
        nativeBuildInputs = with pkgs; [
          bash
          coreutils
          gnused
          jaq
        ];
      }
      ''
        export HOME=$TMPDIR/home
        mkdir -p "$HOME/.codex"
        sed "s|@TEST_HOME@|$HOME|g" ${codexMutableActivation} > "$TMPDIR/activate"
        cat > "$HOME/.codex/config.toml" <<'EOF'
        model = "local-model"
        [projects."/tmp/example-project"]
        trust_level = "trusted"
        [tui.model_availability_nux]
        example = 7
        EOF
        chmod 600 "$HOME/.codex/config.toml"
        bash "$TMPDIR/activate"
        test ! -L "$HOME/.codex/config.toml"
        test -w "$HOME/.codex/config.toml"
        test "$(stat -c %a "$HOME/.codex/config.toml")" = 600
        jaq --from toml -e '
          .model == "${cfg.programs.codex.settings.model}"
          and .projects["/tmp/example-project"].trust_level == "trusted"
          and .tui.model_availability_nux.example == 7
          and .tui.keymap.composer.submit == ["alt-enter"]
          and .tui.keymap.editor.insert_newline == ["enter"]
          and (.tui.status_line | index("context-remaining")) != null
        ' "$HOME/.codex/config.toml"
        cp "$HOME/.codex/config.toml" "$TMPDIR/after-first-activation"
        bash "$TMPDIR/activate"
        cmp "$HOME/.codex/config.toml" "$TMPDIR/after-first-activation"
        printf 'model = [\n' > "$HOME/.codex/config.toml"
        cp "$HOME/.codex/config.toml" "$TMPDIR/invalid-config"
        if bash "$TMPDIR/activate"; then
          echo 'Activation unexpectedly accepted invalid TOML' >&2
          exit 1
        fi
        cmp "$HOME/.codex/config.toml" "$TMPDIR/invalid-config"
        touch $out
      '';
}
