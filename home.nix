{ config, pkgs, ... }:
{
  # 他のカスタム設定モジュールをインポート
  imports = [
    ./neovim
    ./shell
  ];
  programs.home-manager.enable = true;

  # ユーザー情報の設定
  home = {
    username = "shouta";
    homeDirectory = "/home/shouta";
    stateVersion = "23.05";

    packages = with pkgs; [
      fd
      ripgrep
      tree
    ];
  };
  nix = {
    enable = true;
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
