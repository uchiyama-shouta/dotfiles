{
  config,
  lib,
  pkgs,
  ...
}:
let
  unlock = pkgs.writeShellApplication {
    name = "ssh-unlock";
    runtimeInputs = with pkgs; [
      openssh
      systemd
      util-linux
      coreutils
      gawk
      gnugrep
    ];
    text = ''
      export SSH_ASKPASS=${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass
      ${builtins.readFile ./ssh-unlock.sh}
    '';
  };
in
{
  services.ssh-agent.enable = true;
  # All local login frontends use the same user-service socket.
  home = {
    packages = [ unlock ];
    sessionVariablesExtra = ''
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
    '';
    activation.allowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      key="${config.home.homeDirectory}/.ssh/id_ed25519_github.pub"
      if [ -f "$key" ]; then
        run mkdir -p '${config.xdg.stateHome}/git'
        if [[ ! -v DRY_RUN ]]; then
          umask 077
          ${pkgs.gawk}/bin/awk '{print "ninjin0604@gmail.com namespaces=\"git\" " $1 " " $2; exit}' "$key" > '${config.xdg.stateHome}/git/allowed_signers'
        fi
      else
        echo 'SSH signing key not installed; see README.md before committing.' >&2
      fi
    '';
  };
  xdg = {
    configFile = {
      "environment.d/10-ssh-agent.conf".text = ''
        SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR}/ssh-agent
      '';
      "plasma-workspace/env/ssh-agent.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
        '';
      };
      "autostart/ssh-unlock.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Unlock SSH signing key
        Exec=${unlock}/bin/ssh-unlock --gui
        Terminal=false
        X-GNOME-Autostart-enabled=true
      '';
    };
  };
}
