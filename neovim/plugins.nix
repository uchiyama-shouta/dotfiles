pkgs: {
  lazy-nvim = {
    name = "lazy-nvim";
    key = "lazy_nvim";
    pkg = pkgs.vimPlugins.lazy-nvim;
  };

  nvim-tree-lua = {
    name = "nvim-tree-lua";
    key = "nvim_tree_lua";
    pkg = pkgs.vimPlugins.nvim-tree-lua;
  };

  nvim-treesitter = {
    name = "nvim-treesitter";
    key = "nvim_treesitter";
    pkg = pkgs.vimPlugins.nvim-treesitter.withPlugins (
      p: with p; [
        rust
        typescript
        tsx
        javascript
        svelte
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
      ]
    );
  };

  nvim-web-devicons = {
    name = "nvim-web-devicons";
    key = "nvim_web_devicons";
    pkg = pkgs.vimPlugins.nvim-web-devicons;
  };

  nvim-lspconfig = {
    name = "nvim-lspconfig";
    key = "nvim_lspconfig";
    pkg = pkgs.vimPlugins.nvim-lspconfig;
  };

  nvim-cmp = {
    name = "nvim-cmp";
    key = "nvim_cmp";
    pkg = pkgs.vimPlugins.nvim-cmp;
  };

  cmp-nvim-lsp = {
    name = "cmp-nvim-lsp";
    key = "cmp_nvim_lsp";
    pkg = pkgs.vimPlugins.cmp-nvim-lsp;
  };

  cmp-buffer = {
    name = "cmp-buffer";
    key = "cmp_buffer";
    pkg = pkgs.vimPlugins.cmp-buffer;
  };

  cmp-path = {
    name = "cmp-path";
    key = "cmp_path";
    pkg = pkgs.vimPlugins.cmp-path;
  };

  cmp-cmdline = {
    name = "cmp-cmdline";
    key = "cmp_cmdline";
    pkg = pkgs.vimPlugins.cmp-cmdline;
  };

  luasnip = {
    name = "luasnip";
    key = "luasnip";
    pkg = pkgs.vimPlugins.luasnip;
  };

  cmp-luasnip = {
    name = "cmp-luasnip";
    key = "cmp_luasnip";
    pkg = pkgs.vimPlugins.cmp_luasnip;
  };

  conform-nvim = {
    name = "conform.nvim";
    key = "conform_nvim";
    pkg = pkgs.vimPlugins.conform-nvim;
  };

  which-key = {
    name = "which-key.nvim";
    key = "which_key";
    pkg = pkgs.vimPlugins.which-key-nvim;
  };

  comment-nvim = {
    name = "Comment.nvim";
    key = "comment_nvim";
    pkg = pkgs.vimPlugins.comment-nvim;
  };

  telescope-nvim = {
    name = "telescope.nvim";
    key = "telescope_nvim";
    pkg = pkgs.vimPlugins.telescope-nvim;
  };

  telescope-fzf-native-nvim = {
    name = "telescope-fzf-native.nvim";
    key = "telescope_fzf_native_nvim";
    pkg = pkgs.vimPlugins.telescope-fzf-native-nvim;
  };

  plenary = {
    name = "plenary.nvim";
    key = "plenary_nvim";
    pkg = pkgs.vimPlugins.plenary-nvim;
  };

  lualine-nvim = {
    name = "lualine.nvim";
    key = "lualine_nvim";
    pkg = pkgs.vimPlugins.lualine-nvim;
  };

  nightfox = {
    name = "nightfox.nvim";
    key = "nightfox";
    pkg = pkgs.vimPlugins.nightfox-nvim;
  };

  bufferline = {
    name = "bufferline.nvim";
    key = "bufferline";
    pkg = pkgs.vimPlugins.bufferline-nvim;
  };

  hlchunk = {
    name = "hlchunk.nvim";
    key = "hlchunk";
    pkg = pkgs.vimPlugins.hlchunk-nvim;
  };

  nvim-autopairs = {
    name = "nvim-autopairs";
    key = "nvim_autopairs";
    pkg = pkgs.vimPlugins.nvim-autopairs;
  };

  nvim-ts-autotag = {
    name = "nvim-ts-autotag";
    key = "nvim_ts_autotag";
    pkg = pkgs.vimPlugins.nvim-ts-autotag;
  };
  gitsigns = {
    name = "gitsigns.nvim";
    key = "gitsigns_nvim";
    pkg = pkgs.vimPlugins.gitsigns-nvim;
  };

  diffview = {
    name = "diffview.nvim";
    key = "diffview_nvim";
    pkg = pkgs.vimPlugins.diffview-nvim;
  };

  render-markdown-nvim = {
    name = "render-markdown-nvim";
    key = "render_markdown_nvim";
    pkg = pkgs.vimPlugins.render-markdown-nvim;
  };
}
