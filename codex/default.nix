{
  config,
  lib,
  pkgs,
  ...
}:
let
  profile = {
    model = "gpt-6-astra";
    model_reasoning_effort = "low";
    tui = {
      resume_cwd = "session";
      status_line = [
        "model-with-reasoning"
        "context-remaining"
        "current-dir"
        "thread-name"
        "git-branch"
        "branch-changes"
      ];
      status_line_use_colors = true;
      keymap = {
        composer.submit = [ "alt-enter" ];
        editor.insert_newline = [ "enter" ];
      };
    };
  };
in
{
  programs.codex.enable = true;
  home.file.".codex/dotfiles.config.toml".source =
    (pkgs.formats.toml { }).generate "codex-dotfiles-profile"
      profile;
  programs.zsh.initContent = lib.mkAfter ''
    function codex() {
      local codex_arg
      for codex_arg in "$@"; do
        case "$codex_arg" in
          -p|--profile|--profile=*|-p?*) command codex "$@"; return ;;
        esac
      done
      case "''${1-}" in
        login|logout|features|doctor|update|completion|plugin|app-server|agents|remote-control|cloud|exec-server|migrate-rollouts|debug|help)
          command codex "$@" ;;
        *) command codex --profile dotfiles "$@" ;;
      esac
    }
  '';

  # One-time migration from the former read-only Home Manager config.
  # Keep local trust/state without parsing or merging the file.
  home.activation.codexWritableConfig =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
      ''
        codex_config=${lib.escapeShellArg "${config.home.homeDirectory}/.codex/config.toml"}
        if [ -L "$codex_config" ]; then
          case "$(${pkgs.coreutils}/bin/readlink -f "$codex_config")" in
            /nix/store/*-codex-config)
              if [[ ! -v DRY_RUN ]]; then
                codex_temp=$(${pkgs.coreutils}/bin/mktemp "$codex_config.XXXXXXXX")
                ${pkgs.coreutils}/bin/cp --dereference "$codex_config" "$codex_temp"
                ${pkgs.coreutils}/bin/chmod 600 "$codex_temp"
                ${pkgs.coreutils}/bin/mv -T "$codex_temp" "$codex_config"
              fi
              ;;
          esac
        fi
      '';
}
