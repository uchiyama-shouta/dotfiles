{ pkgs, ... }:
{
  imports = [
    ../common/home-manager.nix
    ../../sandbox
  ];
  home = {
    username = "shota";
    homeDirectory = "/home/shota";
    packages = with pkgs; [
      nerd-fonts.hack
    ];
  };
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };
}
