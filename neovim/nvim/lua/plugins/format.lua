return {
  name = "conform.nvim",
  dir = require("config.nix_plugins").conform_nvim,
  event = { "BufReadPre", "BufNewFile" },
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      -- Web
      typescript = { "biome" },
      typescriptreact = { "biome" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      html = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      svelte = {}, -- The Svelte language server bundles its formatter.

      -- Rust/TOML
      rust = { "rustfmt" },
      toml = { "taplo" },

      -- C/C++
      c = { "clang_format" },
      cpp = { "clang_format" },

      -- Nix/Lua/YAML/Shell
      nix = { "nixfmt" },
      lua = { "stylua" },
      yaml = { "prettier" },
      sh = { "shfmt" },
    },
    format_on_save = { lsp_format = "fallback", timeout_ms = 3000 },
  },
}
