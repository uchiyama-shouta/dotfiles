return {
  {
    name = "bufferline.nvim",
    dir = require("config.nix_plugins").bufferline,
    dependencies = { { name = "nvim-web-devicons", dir = require("config.nix_plugins").nvim_web_devicons } },
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
