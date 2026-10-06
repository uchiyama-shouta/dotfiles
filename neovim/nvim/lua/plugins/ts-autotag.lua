return {
  {
    name = "nvim-ts-autotag",
    dir = require("config.nix_plugins").nvim_ts_autotag,
    event = "InsertEnter",
    dependencies = {
      { name = "nvim-treesitter", dir = require("config.nix_plugins").nvim_treesitter },
    },
    config = function()
      require("nvim-ts-autotag").setup({})
    end,
  },
}
