return {
  {
    name = "bufferline.nvim",
    dir = "@bufferline@",
    event = "VeryLazy",
    keys = {
      { "<leader>bl", "<cmd>BufferLinePick<CR>", desc = "Buffer Pick" },
    },
    opts = {
      options = {
        offsets = {
          { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
        },
        diagnostics = "nvim_lsp",

        show_close_icon = false,
        show_buffer_close_icons = true,
        separator_style = "thin",
        always_show_bufferline = true,
      },
    },
  },
}
