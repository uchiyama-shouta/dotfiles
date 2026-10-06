_: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = import ./alias.nix;
    initContent = builtins.readFile ./.zshrc;
    envExtra = builtins.readFile ./.zshenv;
  };
}
