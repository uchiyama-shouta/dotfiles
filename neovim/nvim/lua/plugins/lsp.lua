return {
  {
    "neovim/nvim-lspconfig",
    dir = "@nvim_lspconfig@",
    lazy = false,

    config = function()
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      local on_attach = require("config.lsp_keymaps")

      -- Rust
      lspconfig.rust_analyzer.setup({
        capabilities = caps,
        on_attach = _G.__my_lsp_on_attach,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      })

      -- TypeScript / JavaScript（Node系）
      lspconfig.ts_ls.setup({
        capabilities = caps,
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          if _G.__my_lsp_on_attach then
            _G.__my_lsp_on_attach(client, bufnr)
          end
        end,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- Web
      lspconfig.html.setup({capabilities = caps,})
      lspconfig.cssls.setup({capabilities = caps,})
      lspconfig.jsonls.setup({capabilities = caps,})
      lspconfig.yamlls.setup({capabilities = caps,})

      -- Tailwind / GraphQL / Bash
      lspconfig.tailwindcss.setup({capabilities = caps,})
      lspconfig.graphql.setup({
        capabilities = caps,
        filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
      })
      lspconfig.bashls.setup({capabilities = caps,})

      -- Docker (Dockerfile)
      lspconfig.dockerls.setup({capabilities = caps,})

      -- C/C++
      lspconfig.clangd.setup({capabilities = caps,})

      -- Nix
      lspconfig.nixd.setup({capabilities = caps,})

      -- Lua（Neovim設定）
      lspconfig.lua_ls.setup({
        capabilities = caps,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            format = { enable = false },
          },
        },
      })
    end,
  },
}
