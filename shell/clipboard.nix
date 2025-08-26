# TODO: 下記シェルをやめて、Rustで作り直す。

{ pkgs, ... }:
let
  clip = pkgs.writeShellScriptBin "clip" ''
    set -euo pipefail

    # Wayland
    if command -v wl-copy >/dev/null 2>&1 && [ -n "''${WAYLAND_DISPLAY-}" ]; then
      wl-copy "$@"
      exit $?
    fi

    # X11 (xclip → xsel)
    if command -v xclip >/dev/null 2>&1 && [ -n "''${DISPLAY-}" ]; then
      xclip -selection clipboard "$@"
      exit $?
    fi
    if command -v xsel >/dev/null 2>&1 && [ -n "''${DISPLAY-}" ]; then
      xsel --clipboard --input "$@"
      exit $?
    fi

    # OSC52 fallback（端末/ssh/tmux 用）
    data="$(base64 | tr -d '\n')"
    if [ -n "''${TMUX-}" ]; then
      printf '\ePtmux;\e]52;c;%s\a\e\\' "$data"
    else
      printf '\e]52;c;%s\a' "$data"
    fi
  '';

  pasteclip = pkgs.writeShellScriptBin "pasteclip" ''
    set -euo pipefail

    # Wayland
    if command -v wl-paste >/dev/null 2>&1 && [ -n "''${WAYLAND_DISPLAY-}" ]; then
      wl-paste "$@"
      exit $?
    fi

    # X11 (xclip → xsel)
    if command -v xclip >/dev/null 2>&1 && [ -n "''${DISPLAY-}" ]; then
      xclip -o -selection clipboard "$@"
      exit $?
    fi
    if command -v xsel >/dev/null 2>&1 && [ -n "''${DISPLAY-}" ]; then
      xsel --clipboard --output "$@"
      exit $?
    fi

    echo "pasteclip: no clipboard backend found (install wl-clipboard/xclip/xsel or use a GUI session)" >&2
    exit 1
  '';
in {
  home.packages = with pkgs; [
    wl-clipboard   # wl-copy / wl-paste（Wayland）
    xclip          # X11
    xsel           # X11 alternative
    clip
    pasteclip
  ];
}
