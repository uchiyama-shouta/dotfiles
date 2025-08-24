return {
  {
    name = "tokyonight.nvim",
    dir = "@tokyonight@",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        styles = {
          comments = { italic = false },
          keywords = { bold = true },
          functions = { bold = true },
        },
        on_colors = function(c) c.bg = "#111111" end,
      })
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}
