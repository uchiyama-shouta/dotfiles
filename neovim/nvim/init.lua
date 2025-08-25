vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazypath = "@lazy_nvim@"

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
})

require("config.keymaps")
