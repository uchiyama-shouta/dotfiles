local map = vim.keymap.set
local builtin = require("telescope.builtin")

map("n", "<C-p>", builtin.find_files, { desc = "Find Files (Ctrl-P)" })

map("n", "<leader><space>", builtin.find_files, { desc = "Find Files" })
map("n", "<leader>ff",      builtin.find_files, { desc = "Files" })
map("n", "<leader>fr",      builtin.oldfiles,   { desc = "Recent files" })
map("n", "<leader>fb",      builtin.buffers,    { desc = "Buffers" })

map("n", "<leader>sg",      builtin.live_grep,  { desc = "Search (ripgrep)" })
map("n", "<leader>sw",      builtin.grep_string,{ desc = "Search word under cursor" })
map("n", "<leader>sh",      builtin.help_tags,  { desc = "Help" })
map("n", "<leader>sk",      builtin.keymaps,    { desc = "Keymaps" })
map("n", "<leader>sc",      builtin.commands,   { desc = "Commands" })

map("n", "<leader>sd",      builtin.diagnostics,        { desc = "Diagnostics (workspace)" })
map("n", "<leader>ss",      builtin.lsp_document_symbols, { desc = "Document Symbols" })
map("n", "<leader>sS",      builtin.lsp_workspace_symbols, { desc = "Workspace Symbols" })

map("n", "<leader>bn", ":bnext<CR>",       { desc = "Buffer Next" })
map("n", "<leader>bp", ":bprevious<CR>",   { desc = "Buffer Prev" })
map("n", "<leader>bd", ":bdelete<CR>",     { desc = "Buffer Delete" })
map("n", "<leader>bl", ":BufferLinePick<CR>", { desc = "Buffer Pick" })

map("n", "<leader>f.", function()
  builtin.find_files({ hidden = true, no_ignore = true })
end, { desc = "Find Files (hidden, no_ignore)" })

pcall(function()
  local wk = require("which-key")
  wk.add({
    { "<leader>f", group = "file" },
    { "<leader>s", group = "search" },
    { "<leader>b", group = "buffers" },
  })
end)
