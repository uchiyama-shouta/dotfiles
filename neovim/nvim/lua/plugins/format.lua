return {
  name = "conform.nvim",
  dir = "@conform_nvim@",
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
    format_on_save = { lsp_fallback = true, timeout_ms = 1000 },
  },
}
