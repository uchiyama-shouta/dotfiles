-- neovim/nvim/lua/plugins/completion.lua
return {
  {
    name = "nvim-cmp",
    dir = require("config.nix_plugins").nvim_cmp,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      { name = "cmp-nvim-lsp", dir = require("config.nix_plugins").cmp_nvim_lsp },
      { name = "cmp-buffer", dir = require("config.nix_plugins").cmp_buffer },
      { name = "cmp-path", dir = require("config.nix_plugins").cmp_path },
      { name = "cmp-cmdline", dir = require("config.nix_plugins").cmp_cmdline },
      { name = "LuaSnip", dir = require("config.nix_plugins").luasnip },
      { name = "cmp-luasnip", dir = require("config.nix_plugins").cmp_luasnip },
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- 検索モード（/ と ?）でバッファ補完
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      -- コマンドライン（:）でパス + コマンド補完
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
}
