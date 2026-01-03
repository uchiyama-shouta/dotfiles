return {
  {
    name = "EdenEast/nightfox.nvim",
    dir = "@nightfox@",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = false,
          styles = {
            comments = "italic",
            keywords = "bold",
            functions = "bold",
          }
        }
      })
      vim.cmd.colorscheme("carbonfox")
    end,
  },
}
