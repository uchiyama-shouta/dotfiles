local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("DotfilesLsp", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
      end
      map("n", "K", vim.lsp.buf.hover, "Hover")
      map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
      map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
      map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
      vim.api.nvim_clear_autocmds({ group = group, event = "CursorHold", buffer = args.buf })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.diagnostic.open_float(nil, { focus = false })
        end,
      })
      if client and client:supports_method("textDocument/inlayHint", args.buf) then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      end
    end,
  })
end

return M
