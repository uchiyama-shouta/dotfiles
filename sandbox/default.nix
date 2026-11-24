{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}:
let
  sbx = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.docker-sbx;
  sandbox-create = pkgs.writeShellApplication {
    name = "sandbox-create";
    runtimeInputs = [
      sbx
      pkgs.coreutils
      pkgs.jq
    ];
    text = builtins.readFile ./create.sh;
  };
  sandbox-opencode = pkgs.writeShellApplication {
    name = "sandbox-opencode";
    runtimeInputs = [ sbx ];
    text = builtins.readFile ./opencode.sh;
  };
  sandbox-bundle = pkgs.writeShellApplication {
    name = "sandbox-bundle";
    runtimeInputs = [
      sbx
      pkgs.coreutils
    ];
    text = builtins.readFile ./bundle.sh;
  };
  sandbox-restore-skills = pkgs.writeShellApplication {
    name = "sandbox-restore-skills";
    runtimeInputs = [ sbx ];
    text = ''
      export SANDBOX_APM_FLAKE=${lib.escapeShellArg "github:numtide/llm-agents.nix/${llm-agents.rev}#apm"}
    ''
    + builtins.readFile ./restore-skills.sh;
  };
in
{
  home.file.".codex/skills/sandbox-workflow/SKILL.md".source = ./skill/SKILL.md;
  xdg.configFile."sbx/nix-kit" = {
    source = ./nix-kit;
    recursive = true;
  };
  programs.ssh.settings."*.sbx" = {
    User = "_default_user_";
    ProxyCommand = "${lib.getExe sbx} ssh proxy %n";
    KnownHostsCommand = "${lib.getExe sbx} ssh known-hosts %H";
    UserKnownHostsFile = "${config.xdg.configHome}/sandboxes/sandboxes/ssh/known_hosts";
    StrictHostKeyChecking = "yes";
    IdentityAgent = "none";
    IdentityFile = "/dev/null";
    IdentitiesOnly = "yes";
    ForwardAgent = "no";
    ControlMaster = "no";
    ControlPath = "none";
  };
  home.packages = [
    sbx
    sandbox-create
    sandbox-opencode
    sandbox-bundle
    sandbox-restore-skills
  ];
}
