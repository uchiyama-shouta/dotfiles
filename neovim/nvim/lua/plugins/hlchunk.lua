return {
  {
    name = "hlchunk.nvim",
    dir = "@hlchunk@",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { name = "nvim-treesitter", dir = "@nvim_treesitter@" },
    },
    opts = function()
      local colors = {
        indent = "#3B4261",
        chunk = "#7AA2F7",
      }

      return {
        chunk = {
          enable = true,
          style = {
            { fg = colors.chunk },
          },
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "┌",
            left_bottom = "└",
          },
          notify = false,
          duration = 0,
          delay = 0,
        },

        indent = {
          enable = true,
          style = {
            { fg = colors.indent },
          },
        },
      }
    end,
  },
}
