return {
  name = "nvim-treesitter",
  dir = "@nvim_treesitter@",
  lazy = false,
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      auto_install = false,
      ensure_installed = {},
    })
  end,
}
