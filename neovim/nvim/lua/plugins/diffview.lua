return {
  {
    name = "diffview.nvim",
    dir = "@diffview_nvim@",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
    dependencies = {
      { name = "plenary.nvim", dir = "@plenary_nvim@" },
      { name = "nvim-web-devicons", dir = "@nvim_web_devicons@" },
    },
    keys = {
      { "<leader>go", "<cmd>DiffviewOpen<CR>",                desc = "Diffview Open" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>",               desc = "Diffview Close" },
      { "<leader>gf", "<cmd>DiffviewToggleFiles<CR>",         desc = "Toggle Files Panel" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>",       desc = "File History (buffer)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>",         desc = "File History (repo)" },
    },
    config = function()
      local ok, dv = pcall(require, "diffview")
      if ok then
        dv.setup({
          enhanced_diff_hl = true,
          view = { merge_tool = { layout = "diff3_mixed" } },
          file_panel = { listing_style = "tree" },
        })
      end
    end,
  },
}
