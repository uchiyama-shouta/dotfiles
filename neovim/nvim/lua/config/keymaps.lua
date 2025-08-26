local map = vim.keymap.set

map("n", "<leader>bn", ":bnext<CR>",       { desc = "Buffer Next" })
map("n", "<leader>bp", ":bprevious<CR>",   { desc = "Buffer Prev" })
map("n", "<leader>bd", ":bdelete<CR>",     { desc = "Buffer Delete" })


map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
