{ pkgs, ... }:
{
  imports = [ ../common/home-manager.nix ];
  home = {
    username = "shota";
    homeDirectory = "/home/shota";
    packages = with pkgs; [
      nerd-fonts.hack
      codex
    ];
  };
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };
  nix = {
    enable = true;
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
