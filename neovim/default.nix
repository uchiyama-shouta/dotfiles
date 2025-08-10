{ pkgs, config, lib, replaceVars,... }:
let
  nixPlugins = import ./plugins.nix pkgs;
in
{
  programs.neovim = {
    enable = true;
    plugins = lib.attrValues nixPlugins;
  };
  # xdg.configFile."nvim/init.lua".source = ./init.lua;
  # xdg.configFile."nvim".source = ./nvim;
  xdg.configFile."nvim".source = pkgs.replaceVars ./nvim nixPlugins;
}
