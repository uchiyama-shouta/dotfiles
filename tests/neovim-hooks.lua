_G.dotfiles_errors = {}
local original = vim.notify
vim.notify = function(message, level, opts)
  if level and level >= vim.log.levels.ERROR then
    table.insert(_G.dotfiles_errors, tostring(message))
  end
  original(message, level, opts)
end
