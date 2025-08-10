-- return {
--   "nvim-treesitter/nvim-treesitter",
--   build = ":TSUpdate",
--   lazy = false,
--   config = function()
--     require("nvim-treesitter.configs").setup({
--       highlight = {
--         enable = true,
--       },
--       indent = {
--         enable = true,
--       },
--     })
--   end,
-- }

return {
  name = "nvim-treesitter",
  dir = "@nvim_treesitter@",
  build = ":TSUpdate",
}
