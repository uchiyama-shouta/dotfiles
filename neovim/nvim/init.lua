-- vim.loader.enable()
-- local lazypath = "@lazy_nvim@"
-- vim.opt.rtp:prepend(lazypath)

-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    defaults = { lazy = true },
    spec = "plugins",
})
