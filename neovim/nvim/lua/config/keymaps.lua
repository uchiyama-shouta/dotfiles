local map = vim.keymap.set

map("n", "<leader>bn", ":bnext<CR>", { desc = "Buffer Next" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Buffer Prev" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Buffer Delete" })

map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev Diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
