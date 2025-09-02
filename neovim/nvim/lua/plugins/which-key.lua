return {
  {
    name = "which-key.nvim",
    dir = "@which_key@",
    event = "VeryLazy",
    opts = {},
    config = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>f", group = "file" },
        { "<leader>s", group = "search" },
        { "<leader>b", group = "buffers" },
        { "<leader>g", group = "git" },
      })
    end,
  },
}
