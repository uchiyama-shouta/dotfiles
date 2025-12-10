return {
  {
    "neovim/nvim-lspconfig",
    dir = "@nvim_lspconfig@",
    event = { "BufReadPre", "BufNewFile" },

    config = function()
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      local on_attach = require("config.lsp_keymaps")

      -- Rust
      local ra_cmd = vim.fn.expand("~/.nix-profile/bin/rust-analyzer")
      if vim.fn.filereadable(ra_cmd) == 0 then
        ra_cmd = "rust-analyzer"
      end
      lspconfig.rust_analyzer.setup({
        cmd = { ra_cmd },
        capabilities = caps,
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = true,
            check = {
              command = "clippy",
            },
          },
        },
      })

      -- TypeScript / JavaScript（Node系）
      lspconfig.ts_ls.setup({
        capabilities = caps,
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          on_attach(client, bufnr)
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
            preferences = { importModuleSpecifier = "non-relative" },
          },
          javascript = {
            preferences = { importModuleSpecifier = "non-relative" }, -- ★JS側も
          },
        },
      })

      -- Web
      lspconfig.html.setup({ capabilities = caps })
      lspconfig.cssls.setup({ capabilities = caps })
      lspconfig.jsonls.setup({ capabilities = caps })
      lspconfig.yamlls.setup({ capabilities = caps })

      -- Tailwind / GraphQL / Bash
      lspconfig.tailwindcss.setup({ capabilities = caps })
      lspconfig.graphql.setup({
        capabilities = caps,
        filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
      })
      lspconfig.bashls.setup({ capabilities = caps, on_attach = on_attach })

      -- Docker (Dockerfile)
      lspconfig.dockerls.setup({ capabilities = caps, on_attach = on_attach })

      -- C/C++
      lspconfig.clangd.setup({ capabilities = caps, on_attach = on_attach })

      -- Nix
      lspconfig.nixd.setup({ capabilities = caps, on_attach = on_attach })

      -- Lua（Neovim設定）
      lspconfig.lua_ls.setup({
        capabilities = caps,
        on_attach = on_attach,
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
