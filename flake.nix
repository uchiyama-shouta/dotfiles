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

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      flake-utils,
      rust-overlay,
      ...
    }:
    let
      overlays = [
        (import rust-overlay)
        (import ./overlays/codex.nix)
      ];
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        # nix fmt が使うフォーマッタ（systemごと）
        formatter = pkgs.nixfmt-tree;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            stylua
            statix
            shellcheck
          ];
        };
        checks = import ./tests/checks.nix { inherit pkgs self; };
      }
    )
    // {
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
      };
      nixosConfigurations = {
        shota-nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            inherit overlays;
          };
          modules = [
            ./hosts/shota-nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.shota = import ./hosts/shota-nixos/home-manager.nix;
              };
            }
          ];
        };
      };
    };
}
