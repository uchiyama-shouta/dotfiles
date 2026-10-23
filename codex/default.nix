{
  programs.codex = {
    enable = true;
    settings = {
      model = "gpt-6-astra";
      model_reasoning_effort = "low";
      tui = {
        screen_reader_detection_done = true;
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
        model_availability_nux = {
          gpt-6-astra = 1;
          "gpt-6.1-sol" = 4;
        };
        keymap = {
          composer.submit = [ "alt-enter" ];
          editor.insert_newline = [ "enter" ];
        };
      };
    };
  };
}
