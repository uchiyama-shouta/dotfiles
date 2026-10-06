return {
  {
    name = "which-key.nvim",
    dir = require("config.nix_plugins").which_key,
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "file" },
        { "<leader>s", group = "search" },
        { "<leader>b", group = "buffers" },
        { "<leader>g", group = "git" },
      })
    end,
  },
}
