{ pkgs, llm-agents, ... }:
{
  imports = [ ../common/home-manager.nix ];
  xdg.configFile."sbx/nix-kit" = {
    source = ../../sandbox/nix-kit;
    recursive = true;
  };
  home = {
    username = "shouta";
    homeDirectory = "/home/shouta";
    packages = [ llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.docker-sbx ];
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
