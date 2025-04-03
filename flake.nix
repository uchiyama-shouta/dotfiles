{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        uchiyamashouta = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./cli
            ./gui
            {
              nix = {
                package = pkgs.nix;
                settings.experimental-features = "nix-command flakes";
              };
              programs.home-manager.enable = true;

              home = {
                stateVersion = "23.05";
                username = "uchiyamashouta";
                homeDirectory = "/Users/uchiyamashouta";

                packages = with pkgs; [
                  # CLI
                  tree

                  # GUI
                  # wezterm

                  # Languages
                  ## JS/TS
                  nodePackages_latest.nodejs
                  bun
                  pnpm

                  ## rust
                  rustup
                ];
              };
            }
          ];
        };
      };
      formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixpkgs-fmt;
    };
}
