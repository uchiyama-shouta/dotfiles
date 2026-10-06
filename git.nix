{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    delta
    gh
  ];

  imports = [ ./shell/ssh-agent.nix ];

  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "utiyama";
          email = "ninjin0604@gmail.com";
          signingkey = "~/.ssh/id_ed25519_github.pub";
        };
        alias.lg = "log --graph --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        init.defaultBranch = "main";

        pull.rebase = true;
        rebase.autoStash = true;
        rebase.updateRefs = true;

        fetch.prune = true;
        fetch.pruneTags = false;

        push.autoSetupRemote = true;
        push.followTags = true;

        core = {
          autocrlf = "false";
          safecrlf = "warn";
        };

        # 署名：軽量な SSH 署名（既存の SSH 鍵を流用）
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "${config.xdg.stateHome}/git/allowed_signers";
        commit.gpgsign = true;
        tag.gpgsign = true;

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
        "!.env.example"
        "!.env.sample"
        "!.env.template"
      ];

    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identitiesOnly = true;
          identityFile = "~/.ssh/id_ed25519_github";
          extraOptions = {
            AddKeysToAgent = "yes";
          };
        };
      };
    };
  };
}
