-- Options are automatically loaded before lazy.nvim startup.

-- === Omarchy defaults — do not remove ===
-- remote_clipboard gives OSC-52 yank/paste inside tmux and over SSH.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- === Ported from RonyEA/nvim on 2026-08-26 ===

-- LazyVim's lang.python extra defaults to pyright. This must be set here, in
-- options.lua, because it is read when the extra's spec is evaluated at lazy
-- startup -- setting it from a plugin spec is too late. Without it,
-- `pyright = false` in lua/plugins/lsp.lua disables pyright and nothing
-- replaces it, leaving Python with no language server at all.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Quieter diagnostics. Inline virtual text for ERRORS only -- with
-- basedpyright on data-analysis code, showing warnings inline makes the
-- buffer unreadable. Warnings still get an underline and appear in the
-- float, Trouble and the statusline.
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR },
    source = "if_many",
    spacing = 2,
    prefix = "●",
  },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = "if_many" },
})
