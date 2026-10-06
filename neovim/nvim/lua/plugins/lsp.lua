return {
  {
    "neovim/nvim-lspconfig",
    dir = require("config.nix_plugins").nvim_lspconfig,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { { name = "cmp-nvim-lsp", dir = require("config.nix_plugins").cmp_nvim_lsp } },

    config = function()
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local enabled = {}
      local function setup(name, opts)
        vim.lsp.config(name, opts)
        table.insert(enabled, name)
      end
      require("config.lsp_keymaps").setup()

      -- Rust
      setup("rust_analyzer", {
        capabilities = caps,
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
      setup("ts_ls", {
        capabilities = caps,
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
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
      setup("html", { capabilities = caps })
      setup("cssls", { capabilities = caps })
      setup("jsonls", { capabilities = caps })
      setup("yamlls", { capabilities = caps })

      -- Tailwind / GraphQL / Bash
      setup("tailwindcss", { capabilities = caps })
      setup("graphql", {
        capabilities = caps,
        filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
      })
      setup("bashls", { capabilities = caps })

      -- Docker (Dockerfile)
      setup("dockerls", { capabilities = caps })

      -- C/C++
      setup("clangd", { capabilities = caps })

      -- Nix
      setup("nixd", { capabilities = caps })

      -- Lua（Neovim設定）
      setup("lua_ls", {
        capabilities = caps,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            format = { enable = false },
          },
        },
      })

      setup("svelte", {
        capabilities = caps,
        root_markers = {
          "svelte.config.js",
          "svelte.config.ts",
          "vite.config.js",
          "vite.config.ts",
          "package.json",
          ".git",
        },
        settings = {
          svelte = {
            plugin = {
              typescript = {
                enable = true,
              },
            },
          },
        },
      })
      vim.lsp.enable(enabled)
    end,
  },
}
