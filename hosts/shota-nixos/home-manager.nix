{ config, pkgs, ... }: {
  # 他のカスタム設定モジュールをインポート
  imports = [ ../../neovim ../../neovim/tools.nix ../../shell ../../git.nix ../../tmux.nix ];

  programs.home-manager.enable = true;

  programs.firefox = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  # ユーザー情報の設定
  home = {
    stateVersion = "23.05";

    username = "shota";
    homeDirectory = "/home/shota";

    packages = with pkgs; [
      tree
      rust-bin.stable.latest.default
      nodejs_22
      pnpm
      nerd-fonts.hack
      codex
    ];
  };
}