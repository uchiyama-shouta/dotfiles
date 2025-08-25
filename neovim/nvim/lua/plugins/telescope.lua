return {
  {
    name = "telescope.nvim",
    dir = "@telescope_nvim@",
    dependencies = { { name = "plenary.nvim", dir = "@plenary_nvim@" } },
    lazy = false,
    opts = {
      defaults = {
        mappings = { i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" } }
      },
    },
  },
  {
    name = "telescope-fzf-native.nvim",
    dir = "@telescope_fzf_native_nvim@",
    build = "make",
    config = function() pcall(function() require("telescope").load_extension("fzf") end) end
  },
}
