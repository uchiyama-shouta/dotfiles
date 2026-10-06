{ pkgs, ... }:

{
  # hardware-configuration.nix not present; remove or generate if needed
  imports = [ ./hardware-configuration.nix ];

  # ホスト名とタイムゾーン、ロケール
  networking.hostName = "shota-nixos";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  # Nix の設定（flakes と nix-command を有効化）
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # NetworkManager を有効化
  networking.networkmanager.enable = true;

  # ユーザー作成
  users.users.shota = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" "uinput" ];
    shell = pkgs.zsh;
  };

  # GUI (KDE Plasma 6 + SDDM)
  services.xserver.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;


  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = true;
    capSysAdmin = true;
  };

  # Minimal file system and bootloader configuration to satisfy flake checks
  # fileSystems."/" = {
  #   device = "/dev/null";
  #   fsType = "tmpfs";
  # };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  boot.loader.grub.devices = [ "/dev/null" ];

  # Enable zsh to match user shell configuration
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    git

    libva
    libva-utils

    # intel-media-driver
    # vaapiIntel
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
}
