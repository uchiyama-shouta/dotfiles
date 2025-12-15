{
  description = "Home Manager configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, rust-overlay, ... }:
    let overlays = [ (import rust-overlay) ];
    in flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system overlays; };
      in {
        # nix fmt が使うフォーマッタ（systemごと）
        formatter = pkgs.nixfmt-classic;
      }) // {
        homeConfigurations = {
          shouta-wsl = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              inherit overlays;
            };
            modules = [
              ./hosts/shouta/home-manager.nix
            ];
          };

          shota-ubuntu = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              inherit overlays;
            };
            modules = [
              ./hosts/shota/home-manager.nix
            ];
          };
        };
      };
}

