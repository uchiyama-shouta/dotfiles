pkgs: {
  lazy-nvim = {
    name = "lazy-nvim";
    dirVar = "lazy_nvim";
    pkg = pkgs.vimPlugins.lazy-nvim;
  };

  nvim-tree-lua = {
    name = "nvim-tree-lua";
    dirVar = "nvim_tree_lua";
    pkg = pkgs.vimPlugins.nvim-tree-lua;
  };

  nvim-treesitter = {
    name = "nvim-treesitter";
    dirVar = "nvim_treesitter";
    pkg = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
      rust
      typescript
      tsx
      javascript
      html
      css
      toml
      json
      yaml
      bash
      nix
      c
      lua
      vim
      vimdoc
      markdown
      markdown_inline
    ]);
  };

  nvim-web-devicons = {
    name = "nvim-web-devicons";
    dirVar = "nvim_web_devicons";
    pkg = pkgs.vimPlugins.nvim-web-devicons;
  };

  nvim-lspconfig = {
    name = "nvim-lspconfig";
    dirVar = "nvim_lspconfig";
    pkg = pkgs.vimPlugins.nvim-lspconfig;
  };

  nvim-cmp = {
    name = "nvim-cmp";
    dirVar = "nvim_cmp";
    pkg = pkgs.vimPlugins.nvim-cmp;
  };

  cmp-nvim-lsp = {
    name = "cmp-nvim-lsp";
    dirVar = "cmp_nvim_lsp";
    pkg = pkgs.vimPlugins.cmp-nvim-lsp;
  };

  cmp-buffer = {
    name = "cmp-buffer";
    dirVar = "cmp_buffer";
    pkg = pkgs.vimPlugins.cmp-buffer;
  };

  cmp-path = {
    name = "cmp-path";
    dirVar = "cmp_path";
    pkg = pkgs.vimPlugins.cmp-path;
  };

  cmp-cmdline = {
    name = "cmp-cmdline";
    dirVar = "cmp_cmdline";
    pkg = pkgs.vimPlugins.cmp-cmdline;
  };

  luasnip = {
    name = "luasnip";
    dirVar = "luasnip";
    pkg = pkgs.vimPlugins.luasnip;
  };

  cmp-luasnip = {
    name = "cmp-luasnip";
    dirVar = "cmp_luasnip";
    pkg = pkgs.vimPlugins.cmp_luasnip;
  };

  conform-nvim = {
    name = "conform.nvim";
    dirVar = "conform_nvim";
    pkg = pkgs.vimPlugins.conform-nvim;
  };

  which-key = {
    name = "which-key.nvim";
    dirVar = "which_key";
    pkg = pkgs.vimPlugins.which-key-nvim;
  };

  comment-nvim = {
    name = "Comment.nvim";
    dirVar = "comment_nvim";
    pkg = pkgs.vimPlugins.comment-nvim;
  };

  telescope-nvim = {
    name = "telescope.nvim";
    dirVar = "telescope_nvim";
    pkg = pkgs.vimPlugins.telescope-nvim;
  };

  telescope-fzf-native-nvim = {
    name = "telescope-fzf-native.nvim";
    dirVar = "telescope_fzf_native_nvim";
    pkg = pkgs.vimPlugins.telescope-fzf-native-nvim;
  };

  plenary = {
    name = "plenary.nvim";
    dirVar = "plenary_nvim";
    pkg = pkgs.vimPlugins.plenary-nvim;
  };

  lualine-nvim = {
    name = "lualine.nvim";
    dirVar = "lualine_nvim";
    pkg = pkgs.vimPlugins.lualine-nvim;
  };

  tokyonight = {
    name = "tokyonight.nvim";
    dirVar = "tokyonight";
    pkg = pkgs.vimPlugins.tokyonight-nvim;
  };

  bufferline = {
    name = "bufferline.nvim";
    dirVar = "bufferline";
    pkg = pkgs.vimPlugins.bufferline-nvim;
  };

  hlchunk = {
    name = "hlchunk.nvim";
    dirVar = "hlchunk";
    pkg = pkgs.vimPlugins.hlchunk-nvim;
  };
}
