return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 30,
        side = "left",
      },
      filters = {
        dotfiles = false,
      },
    })

    -- キーマップの例（VSCode風）
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
  end,
}
