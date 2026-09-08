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

-- Diagnostics, inlay hints and spell check all start OFF -- a quiet buffer on
-- open. None of this is permanent; each has a LazyVim toggle:
--   <leader>ud  diagnostics   (comes back with the config above)
--   <leader>uh  inlay hints   (see inlay_hints in lua/plugins/lsp.lua)
--   <leader>us  spelling      (per buffer; see lua/config/autocmds.lua)
vim.diagnostic.enable(false)
vim.opt.spell = false

-- Soft-wrap everywhere at the window edge instead of letting long lines run off
-- screen. LazyVim ships `wrap = false`; this flips it globally.
--   linebreak    break at word boundaries, not mid-word
--   breakindent  keep wrapped continuation lines at the original indent
--   showbreak    marker so a continuation line is visually distinct
-- Nothing is inserted into the file -- this is display-only, 'textwidth' and
-- formatting are untouched.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "

-- With wrap on, j/k jump a whole logical line at a time, which feels like the
-- cursor is skipping. Move by screen line unless a count was given (so 5j still
-- means 5 real lines, and relative-number jumps keep working).
vim.keymap.set({ "n", "x" }, "j", function()
  return vim.v.count > 0 and "j" or "gj"
end, { expr = true, desc = "Down (by screen line)" })
vim.keymap.set({ "n", "x" }, "k", function()
  return vim.v.count > 0 and "k" or "gk"
end, { expr = true, desc = "Up (by screen line)" })

-- No highlight on the line the cursor sits on. LazyVim turns 'cursorline' on by
-- default; with a transparent background that band reads as a smear.
vim.opt.cursorline = false
