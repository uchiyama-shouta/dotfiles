return {
  name = "render-markdown-nvim",
  dir = "@render_markdown_nvim@",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown" },
  keys = {
    { "<Space>sm", ":RenderMarkdown toggle<CR>" },
  },
  opts = {},
}
