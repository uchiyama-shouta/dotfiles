return {
  {
    name = "nvim-autopairs",
    dir = require("config.nix_plugins").nvim_autopairs,
    event = "InsertEnter",
    dependencies = { { name = "nvim-cmp", dir = require("config.nix_plugins").nvim_cmp } },
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true,
      })

      local cmp = require("cmp")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}
