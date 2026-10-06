{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "25.11";

  # ホスト名とタイムゾーン、ロケール
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  # Nix の設定（flakes と nix-command を有効化）
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # NetworkManager を有効化

  # ユーザー作成
  users.users.shota = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "uinput"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  # GUI (KDE Plasma 6 + SDDM)

  virtualisation.docker.enable = true;
  # Pairing/streaming only from the home LAN; the web UI (47990) stays local.

  # Enable zsh to match user shell configuration
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    git

    libva
    libva-utils

  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
  networking = {
    hostName = "shota-nixos";
    networkmanager.enable = true;
    firewall.extraCommands = ''
      iptables -A nixos-fw -s 192.168.3.0/24 -p tcp -m multiport --dports 47984,47989,48010 -j nixos-fw-accept
      iptables -A nixos-fw -s 192.168.3.0/24 -p udp -m multiport --dports 47998,47999,48000,48002,48010 -j nixos-fw-accept
    '';
  };
  services = {
    xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    sunshine = {
      enable = true;
      openFirewall = false;
      autoStart = true;
      capSysAdmin = true;
      # DRM/KMS capture needs CAP_SYS_ADMIN; Sunshine enables uinput itself.
      settings = {
        locale = "ja";
        origin_web_ui_allowed = "pc";
        upnp = "disabled";
        address_family = "ipv4";
      };
    };
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.enable = false;
    };
  };
}
