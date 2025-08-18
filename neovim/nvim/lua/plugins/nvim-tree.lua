return  {
  name = "nvim-tree-lua",
  dir = "@nvim_tree_lua@",
  lazy = false,
  init = function()
    -- 推奨: netrwを無効化
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
  },
  opts = {
    sync_root_with_cwd = true,
    update_focused_file = { enable = true },
    renderer = {
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
        },
      },
    },
  },
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
  end,
}
