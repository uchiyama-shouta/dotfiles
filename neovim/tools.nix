# neovim/tools.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Utility
    ripgrep
    fd
    lazygit
    jq

    # Rust
    rust-bin.stable.latest.rust-analyzer
    # cargo
    # clippy
    # rustfmt

    # toml LSP/formatter
    taplo

    # Node / Web
    typescript-language-server
    svelte-language-server
    ##  html / css / json
    vscode-langservers-extracted

    yaml-language-server
    tailwindcss-language-server
    graphql-language-service-cli
    prettier # HTML/CSS/MD/JSONのfmt用
    biome # TS/JS fmt+lint

    # Nix
    nixd
    nixfmt
    statix

    # C/C++
    clang-tools

    # Lua（Neovim設定用
    lua-language-server
    stylua

    # Bash / Shell
    bash-language-server
    shellcheck
    shfmt

    # Docker
    dockerfile-language-server
    docker-compose-language-service
  ];
}
