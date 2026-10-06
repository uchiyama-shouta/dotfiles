return {
  {
    name = "diffview.nvim",
    dir = require("config.nix_plugins").diffview_nvim,
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
    dependencies = {
      { name = "plenary.nvim", dir = require("config.nix_plugins").plenary_nvim },
      { name = "nvim-web-devicons", dir = require("config.nix_plugins").nvim_web_devicons },
    },
    keys = {
      { "<leader>go", "<cmd>DiffviewOpen<CR>", desc = "Diffview Open" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Diffview Close" },
      { "<leader>gf", "<cmd>DiffviewToggleFiles<CR>", desc = "Toggle Files Panel" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File History (buffer)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "File History (repo)" },
    },
    config = function()
      local dv = require("diffview")
      dv.setup({
        enhanced_diff_hl = true,
        view = { merge_tool = { layout = "diff3_mixed" } },
        file_panel = { listing_style = "tree" },
      })
    end,
  },
}
