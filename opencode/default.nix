{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    mutableSettings = true;
    validateFiles.config = true;

    settings = {
      mcp.playwright = {
        type = "local";
        command = [
          "${pkgs.nodejs_22}/bin/npx"
          "-y"
          "@playwright/mcp@latest"
          "--cdp-endpoint"
          "http://127.0.0.1:9222"
        ];
        enabled = true;
      };
      permission = {
        edit = "allow";
        read = {
          "*" = "allow";
          "*.env" = "ask";
          "*.env.*" = "ask";
          "*.env.example" = "allow";
        };
        external_directory = "ask";
        webfetch = "ask";
        bash = {
          "*" = "ask";
          # ホスト環境を変更する操作は拒否する
          "home-manager switch*" = "deny";
          "nixos-rebuild switch*" = "deny";
          "sudo*" = "deny";
        };
      };
    };
  };
  xdg.configFile."opencode/AGENTS.md".source = ../agents/AGENTS.md;
}
