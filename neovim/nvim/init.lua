vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazypath = require("config.nix_plugins").lazy_nvim
for _, path in ipairs(require("config.nix_plugins").treesitter_runtime) do
  vim.opt.rtp:append(path)
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  defaults = { lazy = true },
  spec = "plugins",

  lockfile = vim.fn.stdpath("data") .. "/lazy/lazy-lock.json",
  performance = {
    reset_packpath = false,
    rtp = { reset = false },
  },
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
})

require("config.keymaps")
require("config.options")
