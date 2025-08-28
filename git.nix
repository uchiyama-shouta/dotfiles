{ pkgs, ... }: {
  home.packages = with pkgs; [ git delta gh ];

  programs.git = {
    enable = true;

    userName = "utiyama";
    userEmail = "ninjin0604@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";

      pull.rebase = true;
      rebase.autoStash = true;
      rebase.updateRefs = true;

      fetch.prune = true;
      fetch.pruneTags = true;

      push.autoSetupRemote = true;
      push.followTags = true;

      core = {
        autocrlf = "false";
        safecrlf = "warn";
      };

      # 署名：軽量な SSH 署名（既存の SSH 鍵を流用）
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;
      user.signingkey = "~/.ssh/id_ed25519_github.pub";

      color.ui = "auto";
      diff.renames = true;
      merge.renames = true;
      rerere.enabled = true;

      maintenance.auto = 1;
      maintenance.strategy = "incremental";
      gc.writeCommitGraph = true;

      credential.helper = "!gh auth git-credential";
    };

    ignores = [
      ".DS_Store"
      "node_modules/"
      "dist/"
      "target/"
      "*.log"
      ".env"
      ".env.*"
      "*.lock"
      "*-lock.*"
    ];

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };

    aliases = {
      lg =
        "log --graph --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519_github";
      };
    };

    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  services.ssh-agent.enable = true;
}
