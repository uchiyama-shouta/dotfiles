{ pkgs, ... }:
{
  programs.codex = {
    enable = true;
    mutableSettings = true;
    settings = {
      mcp_servers.playwright = {
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [
          "-y"
          "@playwright/mcp@latest"
        ];
      };
      model = "gpt-6-astra";
      model_reasoning_effort = "low";
      tui = {
        resume_cwd = "session";
        status_line = [
          "model-with-reasoning"
          "context-remaining"
          "current-dir"
          "thread-name"
          "git-branch"
          "branch-changes"
        ];
        status_line_use_colors = true;
        keymap = {
          composer.submit = [ "alt-enter" ];
          editor.insert_newline = [ "enter" ];
        };
      };
    };
  };
  home.file.".codex/AGENTS.md".source = ../agents/AGENTS.md;
}
