return {
  {
    name = "telescope.nvim",
    dir = "@telescope_nvim@",
    cmd = "Telescope",
    dependencies = {
      { name = "plenary.nvim", dir = "@plenary_nvim@" },
      { name = "telescope-fzf-native.nvim", dir = "@telescope_fzf_native_nvim@", build = "make" },
    },
    keys = {
      {
        "<C-p>",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find Files (Ctrl-P)",
      },
      {
        "<leader><space>",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Files",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>sg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Search (ripgrep)",
      },
      {
        "<leader>sw",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "Search word under cursor",
      },
      {
        "<leader>sh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help",
      },
      {
        "<leader>sk",
        function()
          require("telescope.builtin").keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>sc",
        function()
          require("telescope.builtin").commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>sd",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "Diagnostics (workspace)",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Document Symbols",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_workspace_symbols()
        end,
        desc = "Workspace Symbols",
      },
      {
        "<leader>f.",
        function()
          require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
        end,
        desc = "Find (hidden, no_ignore)",
      },
    },
    opts = {
      defaults = {
        mappings = { i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" } },
      },
    },
    config = function(_, opts)
      local ok, telescope = pcall(require, "telescope")
      if ok then
        telescope.setup(opts)
        pcall(telescope.load_extension, "fzf")
      end
    end,
  },
}
