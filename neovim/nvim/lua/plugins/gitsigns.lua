return {
  {
    name = "gitsigns.nvim",
    dir = "@gitsigns_nvim@",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { name = "plenary.nvim", dir = "@plenary_nvim@" },
    },
    keys = {
      { "]h", function() require("gitsigns").next_hunk() end, desc = "Next Hunk" },
      { "[h", function() require("gitsigns").prev_hunk() end, desc = "Prev Hunk" },

      { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage Hunk" },
      { "<leader>gr", function() require("gitsigns").reset_hunk() end,  desc = "Reset Hunk" },
      { "<leader>gp", function() require("gitsigns").preview_hunk_inline() end, desc = "Preview Hunk (inline)" },

      { "<leader>gS", function() require("gitsigns").stage_buffer() end, desc = "Stage Buffer" },
      { "<leader>gR", function() require("gitsigns").reset_buffer() end,  desc = "Reset Buffer" },

      { "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line" },
      { "<leader>gB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle Line Blame" },

      { "<leader>gD", function() require("gitsigns").diffthis() end,    desc = "Diff This" },
      { "<leader>gd", function() require("gitsigns").diffthis("~") end, desc = "Diff This (~)" },
    },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▁" },
        topdelete    = { text = "▔" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame_opts = { delay = 500 },
      _threaded = true,
    },
  },
}
