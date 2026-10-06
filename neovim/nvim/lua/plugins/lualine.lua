return {
  {
    name = "lualine.nvim",
    dir = require("config.nix_plugins").lualine_nvim,
    dependencies = { { name = "nvim-web-devicons", dir = require("config.nix_plugins").nvim_web_devicons } },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
      },
    },
  },
}
