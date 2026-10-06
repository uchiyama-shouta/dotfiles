return {
  {
    name = "Comment.nvim",
    dir = require("config.nix_plugins").comment_nvim,
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gcc", mode = "n" },
      { "gbc", mode = "n" },
    },
    opts = {},
  },
}
