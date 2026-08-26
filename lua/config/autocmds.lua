-- Autocmds are automatically loaded on the VeryLazy event.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Ported from RonyEA/nvim on 2026-08-26. The original also carried a
-- ColorScheme autocmd that stripped `bg` from ~25 highlight groups; that is
-- deliberately NOT here, because Omarchy's own plugin/after/transparency.lua
-- already does it across ~40 groups and is re-sourced by Omarchy's theme
-- hot-reload shim after every theme change.

-- Activate the nearest .venv for the whole editor.
--
-- This is the keystone of the Python workflow: it is what makes basedpyright,
-- dap-python and neotest all agree on one interpreter, instead of each
-- resolving its own. The original config had three near-identical copies of
-- this logic in iron.lua, dap-python.lua and testing.lua; LazyVim's lang.python
-- extra handles those, so only this one remains.
local function activate_venv()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = buf ~= "" and vim.fs.dirname(buf) or (vim.uv or vim.loop).cwd()

  local venv = vim.fs.find(".venv", { path = start, upward = true, type = "directory" })[1]
  if not venv then
    return
  end

  local venv_bin = venv .. "/bin"
  if vim.fn.isdirectory(venv_bin) == 0 then
    return
  end

  vim.env.VIRTUAL_ENV = venv
  vim.env.PATH = venv_bin .. ":" .. (vim.env.PATH or "")
  vim.g.python3_host_prog = venv .. "/bin/python"
end

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("ron_venv", { clear = true }),
  callback = function()
    pcall(activate_venv)
  end,
})

vim.filetype.add({
  extension = {
    jsonl = "json",
    ndjson = "json",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ron_quarto_conceal", { clear = true }),
  pattern = { "quarto", "rmd" },
  callback = function()
    -- Keep fenced chunk markers like ```{r} visible. This intentionally fights
    -- render-markdown.nvim, which would otherwise conceal them -- in a Quarto
    -- document the chunk header is content, not decoration.
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ""
  end,
})

-- Prose editing. LazyVim's own `lazyvim_wrap_spell` augroup already turns on
-- `wrap` and `spell` for markdown/text/gitcommit, so only `linebreak` is added
-- here -- without it, `wrap` breaks mid-word.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ron_prose", { clear = true }),
  pattern = { "markdown", "text", "gitcommit", "quarto" },
  callback = function()
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})
