{ pkgs, ... }:
{
  imports = [
    ../common/home-manager.nix
    ../../sandbox
  ];
  home = {
    username = "shouta";
    homeDirectory = "/home/shouta";
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
