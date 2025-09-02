return {
  {
    name = "nvim-autopairs",
    dir = "@nvim_autopairs@",
    event = "InsertEnter",
    config = function()
      local ok, npairs = pcall(require, "nvim-autopairs")
      if not ok then
        return
      end
      npairs.setup({
        check_ts = true,
      })

      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },
}
