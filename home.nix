{ config, pkgs, ... }:
{
  # 他のカスタム設定モジュールをインポート
  imports = [
    ./cli
    # ./neovim
    ./shell
  ];

  # ユーザー情報の設定
  home = {
    username = "shouta";
    homeDirectory = "/home/shouta";
    stateVersion = "23.05";

    packages = with pkgs; [
      tree
    ];
    nix = {
      package = pkgs.nix;
      settings.experimental-features = [ "nix-command" "flakes" ];
  };
  };
}
