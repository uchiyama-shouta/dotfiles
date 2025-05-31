pkgs: {
  tools = with pkgs; [
    # Inner tools
    ## For telescope.nvim
    ripgrep

    ## Git TUI
    lazygit

    # Web
    ## HTML/CSS
    nodePackages.vscode-langservers-extracted

    ## JavaScript/TypeScript/Frameworks
    biome
    eslint
    deno
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodePackages."@tailwindcss/language-server"

    ## GraphQL
    nodePackages.graphql-language-service-cli

    # Programming languages
    ## Lua
    lua-language-server
    stylua

    ## Nix
    nil
    nixfmt-rfc-style

    # Configuration languages
    ## TOML
    taplo

    # Bash
    nodePackages.bash-language-server

    # C/C++
    clang-tools

    # Docker
    nodePackages.dockerfile-language-server-nodejs

    # Protocol Buffers
    buf

    # Shell
    shellcheck
    shfmt
  ];
}
