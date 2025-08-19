-- neovim/nvim/lua/plugins/completion.lua
return {
  {
    name = "nvim-cmp",
    dir = "@nvim_cmp@",
    dependencies = {
      { name = "cmp-nvim-lsp",  dir = "@cmp_nvim_lsp@" },
      { name = "cmp-buffer",    dir = "@cmp_buffer@"   },
      { name = "cmp-path",      dir = "@cmp_path@"     },
      { name = "cmp-cmdline",   dir = "@cmp_cmdline@"  },
      { name = "LuaSnip",       dir = "@luasnip@"      },
      { name = "cmp-luasnip",   dir = "@cmp_luasnip@"  },
    },
    lazy = false,

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<Tab>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
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
