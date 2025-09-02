return {
  {
    name = "nvim-ts-autotag",
    dir = "@nvim_ts_autotag@",
    event = "InsertEnter",
    dependencies = {
      { name = "nvim-treesitter", dir = "@nvim_treesitter@" },
    },
    config = function()
      local ok, autotag = pcall(require, "nvim-ts-autotag")
      if ok then
        autotag.setup({})
      end
    end,
  },
}
