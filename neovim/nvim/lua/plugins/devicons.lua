return {
  name = "nvim-web-devicons",
  dir = "@nvim_web_devicons@",
  lazy = false,
  opts = { default = true },
  config = function(_, opts)
    require("nvim-web-devicons").setup(opts)
  end,
}

-- return {
--   "nvim-tree/nvim-web-devicons",
--   lazy = false,
--   opts = { default = true },
--   config = function(_, opts)
--     require("nvim-web-devicons").setup(opts)
--   end,
-- }
