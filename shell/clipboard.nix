# TODO: 下記シェルをやめて、Rustで作り直す。

{ pkgs, ... }:
let
  clip = pkgs.writeShellScriptBin "clip" ''
    set -euo pipefail

    # OSC52
    data="$(base64 | tr -d '\n')"
    if [ -n "''${TMUX-}" ]; then
      printf '\ePtmux;\e]52;c;%s\a\e\\' "$data"
    else
      printf '\e]52;c;%s\a' "$data"
    fi
  '';

in { home.packages = [ clip ]; }
