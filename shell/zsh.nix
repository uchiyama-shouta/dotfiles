{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = (import ./alias.nix);
    initExtra = (builtins.readFile ./.zshrc);
    envExtra = (builtins.readFile ./.zshenv);
  };
}
