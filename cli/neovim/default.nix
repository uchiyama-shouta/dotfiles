{ pkgs, config, ... }:
let
  lsp = with pkgs; [];
  # (p) -> []
  parsers =
    p: with p; [];

  configFile = file: {
    "nvim/${file}".source = pkgs.substituteAll (
      {
        src = ./. + "/${file}";
        ts_parser_dirs = pkgs.lib.pipe (pkgs.vimPlugins.nvim-treesitter.withPlugins parsers).dependencies [
          (map toString)
          (builtins.concatStringsSep ",")
        ];
      }
      #// plugins
    );
  };
  configFiles = files: builtins.foldl' (x: y: x // y) { } (map configFile files);
  ##
in
{
  programs.neovim = {
    enable = true;
    extraPackages = lsp;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
    extraConfig = (builtins.readFile ./init.lua);
  };
}
