-- return {
--   name = "nvim-tree-lua",
--   dir = "@nvim_tree_lua@",
--   lazy = false,
--   config = function()
--     require("nvim-tree").setup({
--       view = {
--         width = 30,
--         side = "left",
--       },
--       filters = {
--         dotfiles = false,
--       },
--     })

--     -- キーマップの例（VSCode風）
--     vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
--   end,
-- }

return  {
  name = "nvim-tree-lua",
  dir = "@nvim_tree_lua@",
  lazy = true,
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
}
