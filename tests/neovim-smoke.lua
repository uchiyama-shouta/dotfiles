local function run()
  local root = assert(vim.env.DOTFILES_TEST_DIR)
  local function fixture(name, lines)
    local path = root .. "/" .. name
    vim.fn.writefile(lines, path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    return path
  end
  -- Exercise the normal file-open path before forcing remaining plugin loads.
  fixture("startup.lua", { "local value = 1" })
  vim.wait(100)
  local lazy = require("lazy")
  local names = {}
  for name in pairs(require("lazy.core.config").plugins) do
    table.insert(names, name)
  end
  lazy.load({ plugins = names })
  vim.api.nvim_exec_autocmds("InsertEnter", {})
  vim.wait(200)
  assert(require("which-key").did_setup, "which-key was not initialized")
  require("telescope").load_extension("fzf")
  assert(not vim.o.autowrite and not vim.o.autowriteall, "implicit saving enabled")
  assert(vim.o.clipboard == "", "clipboard override remains")
  assert(vim.g.clipboard == nil, "custom clipboard provider remains")

  local languages = {
    "rust",
    "typescript",
    "tsx",
    "javascript",
    "svelte",
    "html",
    "css",
    "toml",
    "json",
    "yaml",
    "bash",
    "nix",
    "c",
    "lua",
    "vim",
    "vimdoc",
    "markdown",
    "markdown_inline",
  }
  for _, lang in ipairs(languages) do
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
    assert(vim.treesitter.get_parser(buf, lang), "parser missing: " .. lang)
    vim.treesitter.query.get(lang, "highlights")
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  local path = fixture("example.lua", { "local value=1" })
  assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], "highlight not enabled")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "local value=2" })
  local buf = vim.api.nvim_get_current_buf()
  fixture("other.txt", { "other" })
  vim.api.nvim_exec_autocmds("FocusLost", {})
  assert(vim.fn.readfile(path)[1] == "local value=1", "buffer was saved implicitly")
  vim.api.nvim_set_current_buf(buf)
  vim.cmd.write()
  assert(vim.fn.readfile(path)[1] == "local value = 2", "Lua formatting failed")

  fixture("registers.txt", { "hello", "world" })
  vim.cmd("normal! ggyyp")
  assert(vim.api.nvim_buf_get_lines(0, 0, 2, false)[2] == "hello", "normal yank/paste failed")
  fixture("example.json", { '{"value":1}' })
  vim.cmd.write()
  assert(vim.fn.readfile(root .. "/example.json")[1] == '{ "value": 1 }', "JSON formatting failed")
  for _, example in ipairs({
    { "example.rs", "fn main(){let value=1;}", "let value = 1;" },
    { "example.nix", "{value=1;}", "value = 1;" },
    { "example.ts", "const value={answer:42}", "answer: 42" },
    { "example.md", "#   Hello", "# Hello" },
  }) do
    local formatted = fixture(example[1], { example[2] })
    assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], "highlight missing: " .. example[1])
    vim.cmd.write()
    assert(table.concat(vim.fn.readfile(formatted), "\n"):find(example[3], 1, true), "format failed: " .. example[1])
  end

  -- Attach handlers must be independent of language and idempotent per buffer.
  local original = vim.lsp.get_client_by_id
  vim.lsp.get_client_by_id = function()
    return {
      supports_method = function()
        return false
      end,
    }
  end
  for _ = 1, 2 do
    vim.api.nvim_exec_autocmds("LspAttach", { buffer = 0, data = { client_id = 999999 } })
  end
  vim.lsp.get_client_by_id = original
  assert(
    #vim.api.nvim_get_autocmds({ group = "DotfilesLsp", event = "CursorHold", buffer = 0 }) == 1,
    "duplicate diagnostics autocmd"
  )
  local found = false
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    if map.lhs == "gd" then
      found = true
    end
  end
  assert(found, "common LSP keys missing")

  vim.fn.writefile({ '{"name":"smoke","version":"1.0.0"}' }, root .. "/package.json")
  vim.fn.writefile({ "export default {};" }, root .. "/svelte.config.js")
  fixture("example.svelte", { "<script>let count=1;</script><h1>{count}</h1>" })
  assert(
    vim.wait(15000, function()
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client.name == "svelte" and client:supports_method("textDocument/formatting") then
          return true
        end
      end
      return false
    end, 100),
    "Svelte formatting LSP did not attach"
  )
  local error_message
  require("conform").format({ async = false, timeout_ms = 5000, lsp_format = "fallback" }, function(err)
    error_message = err
  end)
  assert(not error_message, tostring(error_message))
  assert(
    table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("let count = 1", 1, true),
    "Svelte formatter returned no useful edit"
  )
  for _, plugin in pairs(require("lazy.core.config").plugins) do
    assert(not plugin._.error, "plugin failure: " .. plugin.name)
  end
  assert(#_G.dotfiles_errors == 0, table.concat(_G.dotfiles_errors, "\n"))
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  assert(not messages:match("deprecated") and not messages:match("Failed to run"), messages)
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  print("Neovim smoke checks passed")
  vim.cmd("qa!")
end
