vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.list = true
vim.opt.listchars = { space = "·", tab = "→ ", trail = "•" }

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if vim.bo[args.buf].filetype == "markdown" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- indent
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "rust" },
  callback = function()
    vim.bo.shiftwidth  = 4
    vim.bo.tabstop     = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "make" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop   = 8
    vim.bo.shiftwidth= 8
    vim.bo.softtabstop = 0
  end,
})

-- auto save
vim.opt.autowrite = true
vim.opt.autowriteall = true

vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    vim.cmd("silent! wall")
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  callback = function(args)
    local bo = vim.bo[args.buf]
    if bo.modifiable and not bo.readonly and bo.buftype == "" then
      vim.cmd("silent! update")
    end
  end,
})

-- clipboard
vim.opt.clipboard = "unnamed,unnamedplus"

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = function() return {''}, 'v' end,
    ['*'] = function() return {''}, 'v' end,
  },
}
