{ pkgs, ... }:
{
  imports = [ ../common/home-manager.nix ];
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
