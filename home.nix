{ config, pkgs, ... }: {
  # 他のカスタム設定モジュールをインポート
  imports = [ ./neovim ./neovim/tools.nix ./shell ./git.nix ./tmux.nix ];
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  # ユーザー情報の設定
  home = {
    stateVersion = "23.05";

    packages = with pkgs; [
      tree
      rust-bin.stable.latest.default
      nodejs_22
      pnpm
      nerd-fonts.hack
    ];
  };
  nix = {
    enable = true;
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
