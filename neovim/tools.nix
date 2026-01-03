# neovim/tools.nix
{ config, pkgs, ... }:
let np = pkgs.nodePackages;
in {
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
    np.typescript-language-server
    np.svelte-language-server
    ##  html / css / json
    np.vscode-langservers-extracted

    np.yaml-language-server
    np."@tailwindcss/language-server"
    np.graphql-language-service-cli
    np.prettier # HTML/CSS/MD/JSONのfmt用
    biome # TS/JS fmt+lint

    # Nix
    nixd
    nixfmt-classic
    statix

    # C/C++
    clang-tools

    # Lua（Neovim設定用
    lua-language-server
    stylua

    # Bash / Shell
    np.bash-language-server
    shellcheck
    shfmt

    # Docker
    np.dockerfile-language-server-nodejs
    docker-compose-language-service
  ];
}
