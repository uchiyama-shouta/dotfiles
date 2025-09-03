{
  description = "Home Manager configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils"; # formatterのためには必要
  };

  # outputs = { nixpkgs, home-manager, flake-utils, ... }:
  #   let
  #     system = "x86_64-linux";
  #     pkgs = nixpkgs.legacyPackages.${system};
  #   in
  #   {
  #     homeConfigurations = {
  #       shouta = home-manager.lib.homeManagerConfiguration {
  #         inherit pkgs;
  #         modules = [
  #           ./home.nix
  #         ];
  #       };
  #     };
  #   };
  outputs = { nixpkgs, home-manager, flake-utils, ... }: {
    homeConfigurations = {
      shouta-wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          ./home.nix
          { home.username = "shouta"; home.homeDirectory = "/home/shouta"; }
        ];
      };

      shota-ubuntu = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          ./home.nix
          { home.username = "shota"; home.homeDirectory = "/home/shota"; }
        ];
      };
    };
  };
}
