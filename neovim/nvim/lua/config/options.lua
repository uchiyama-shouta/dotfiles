vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.list = true
vim.opt.listchars = { space = "·", tab = "→ ", trail = "•" }
vim.opt.wrap = false

-- indent
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "rust" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "make" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
    vim.bo.softtabstop = 0
  end,
})

-- Files are written explicitly; formatters own whitespace changes.
vim.opt.autowrite = false
vim.opt.autowriteall = false
