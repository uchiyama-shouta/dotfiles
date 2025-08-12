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
    pkg = pkgs.vimPlugins.nvim-treesitter;
  };

  nvim-web-devicons = {
    name = "nvim-web-devicons";
    dirVar = "nvim_web_devicons";
    pkg = pkgs.vimPlugins.nvim-web-devicons;
  };
}
