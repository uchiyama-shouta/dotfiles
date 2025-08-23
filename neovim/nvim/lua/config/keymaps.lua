local map = vim.keymap.set
map("n", "<leader><space>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>sg",      "<cmd>Telescope live_grep<cr>",  { desc = "Search (ripgrep)" })
map("n", "<leader>fb",      "<cmd>Telescope buffers<cr>",    { desc = "Buffers" })
