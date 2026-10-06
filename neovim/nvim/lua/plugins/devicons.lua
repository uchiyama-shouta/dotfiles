return {
  name = "nvim-web-devicons",
  dir = require("config.nix_plugins").nvim_web_devicons,
  event = "VeryLazy",
  opts = { default = true },
  config = function(_, opts)
    require("nvim-web-devicons").setup(opts)
  end,
}
