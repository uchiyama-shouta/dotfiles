{ pkgs, ... }:
{
  imports = [
    ../../neovim
    ../../neovim/tools.nix
    ../../shell
    ../../git.nix
  ];
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  home.stateVersion = "23.05";
  home.packages = with pkgs; [
    tree
    rust-bin.stable.latest.default
    nodejs_22
    pnpm
    docker-client
    docker-compose
  ];
}
