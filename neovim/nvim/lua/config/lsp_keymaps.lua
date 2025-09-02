local function on_attach(_, bufnr)
  local bmap = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
  end
  bmap("n", "K", vim.lsp.buf.hover, "Hover")
  bmap("n", "gd", vim.lsp.buf.definition, "Goto Definition")
  bmap("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
  bmap("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
  bmap("n", "gr", vim.lsp.buf.references, "References")
  bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  bmap("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      vim.diagnostic.open_float(nil, { focus = false })
    end,
  })

  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

return on_attach
