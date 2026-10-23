{ pkgs, ... }:
{
  imports = [ ../common/home-manager.nix ];
  programs.codex.settings.projects = {
    "/home/shouta/Work/framework-benchmark".trust_level = "untrusted";
    "/home/shouta/Work/firefox_extention".trust_level = "trusted";
    "/home/shouta/dotfiles".trust_level = "trusted";
    "/home/shouta/Work/arona-desktop".trust_level = "trusted";
    "/home/shouta/Work/sf6-replay-system".trust_level = "trusted";
  };
  home = {
    username = "shouta";
    homeDirectory = "/home/shouta";
    packages = with pkgs; [ ];
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
