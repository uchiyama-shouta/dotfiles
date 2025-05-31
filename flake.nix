{
  description = "Home Manager configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        homeConfigurations = {
          shouta = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              home-manager.nixosModules.home-manager
              ./home.nix
            ];
          };
          formatter = pkgs.nixpkgs-fmt;
        }
      });
}
