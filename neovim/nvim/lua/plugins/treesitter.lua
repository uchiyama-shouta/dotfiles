return {
  name = "nvim-treesitter",
  dir = require("config.nix_plugins").nvim_treesitter,
  lazy = false,
  config = function()
    local group = vim.api.nvim_create_augroup("DotfilesTreesitter", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang or #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) == 0 then
          return
        end
        vim.treesitter.start(args.buf, lang)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
