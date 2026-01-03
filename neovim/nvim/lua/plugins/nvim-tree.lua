return {
  name = "nvim-tree-lua",
  dir = "@nvim_tree_lua@",
  cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
  keys = {
    { "<leader>ee", "<cmd>NvimTreeToggle<cr>", desc = "Explorer Toggle" },
    { "<leader>ef", "<cmd>NvimTreeFocus<cr>", desc = "Explorer Focus" },
  },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true
  end,
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
  config = function(_, opts)
    require("nvim-tree").setup(vim.tbl_deep_extend("force", opts, {
      view = {
        width = 30,
        side = "left",
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
    }))

    local function nvim_tree_folder_blue()
      vim.api.nvim_set_hl(0, "NvimTreeFolderName", {
        fg = "#0077ff",
      })
      vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", {
        fg = "#0077ff",
      })
    end

    nvim_tree_folder_blue()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = nvim_tree_folder_blue,
    })
  end,
}
