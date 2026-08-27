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
--
-- `spell` is explicitly turned back off: this file is sourced after LazyVim's
-- autocmds, so for a shared filetype this callback runs second and wins. The
-- pattern therefore has to cover every filetype in `lazyvim_wrap_spell`
-- (text, plaintex, typst, gitcommit, markdown), not just the prose ones --
-- otherwise spelling would still come on for, say, a typst file. Wrap is
-- kept; only the spell checker is off. Toggle it per buffer with <leader>us.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ron_prose", { clear = true }),
  pattern = { "markdown", "text", "gitcommit", "quarto", "plaintex", "typst" },
  callback = function()
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.spell = false
  end,
})

-- Heading bands for render-markdown.nvim.
--
-- The plugin links its heading backgrounds to the diff palette -- H1Bg to
-- DiffText, H2Bg to DiffAdd, H3Bg to DiffChange and so on. Those colours mean
-- "added / removed / changed", not "level 1 / 2 / 3", so the result is
-- arbitrary on most themes and unreadable on this one: aether resolves
-- DiffText to #F0F8FF, which puts pink H1 text on a white band, and H5 is
-- white on white.
--
-- Derive each band from that heading's own foreground instead, blended toward
-- the editor background, with the blend weakening as the level deepens. The
-- band then always matches its heading's colour and fades with depth, and it
-- follows whatever theme Omarchy has symlinked in without naming a colour.
local heading_blend = { 0.30, 0.24, 0.19, 0.15, 0.11, 0.08 }

local function render_markdown_bands()
  local function hl(name)
    local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    return ok and value or {}
  end

  -- plugin/after/transparency.lua strips Normal's background, so fall back to
  -- ColorColumn: the theme sets it to the true editor background and
  -- transparency.lua leaves it alone.
  local base = hl("Normal").bg or hl("ColorColumn").bg or (vim.o.background == "dark" and 0x000000 or 0xFFFFFF)

  local function channels(rgb)
    return math.floor(rgb / 65536) % 256, math.floor(rgb / 256) % 256, rgb % 256
  end

  local function blend(rgb, alpha)
    local fr, fg, fb = channels(rgb)
    local br, bg, bb = channels(base)
    local function mix(a, b)
      return math.floor(a * alpha + b * (1 - alpha) + 0.5)
    end
    return mix(fr, br) * 65536 + mix(fg, bg) * 256 + mix(fb, bb)
  end

  for level = 1, 6 do
    local fg = hl("RenderMarkdownH" .. level).fg or hl("@markup.heading." .. level .. ".markdown").fg
    if fg then
      -- No `default = true`: the plugin sets its own links with that flag, so
      -- an explicit definition here takes precedence and survives its reload.
      vim.api.nvim_set_hl(0, "RenderMarkdownH" .. level .. "Bg", { bg = blend(fg, heading_blend[level]) })
    end
  end

  -- The plugin caches the combined fg+bg groups it actually renders with, so
  -- the new bands only take effect once that cache is rebuilt.
  pcall(function()
    require("render-markdown.core.colors").reload()
  end)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ron_markdown_bands", { clear = true }),
  callback = function()
    -- Deferred so this lands after the plugin's own ColorScheme handler and
    -- after transparency.lua is re-sourced by the theme hot-reload shim.
    vim.schedule(render_markdown_bands)
  end,
})

-- Also run once the plugin itself is loaded. render-markdown is lazy-loaded on
-- filetype, so at startup its highlight groups may not exist yet; this file is
-- sourced on VeryLazy, well before the first markdown buffer is opened.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ron_markdown_bands_init", { clear = true }),
  pattern = { "markdown", "quarto", "rmd" },
  callback = function()
    vim.schedule(render_markdown_bands)
  end,
})

vim.schedule(render_markdown_bands)

-- Drop the stray `[No Name]` buffer left behind by `nvim <dir>`.
--
-- Starting Neovim on a directory makes buffer 1 that directory. neo-tree
-- hijacks netrw and wipes it, and Neovim has to hand the now-empty window
-- *some* buffer, so it creates a fresh, listed, unnamed one. Opening a file
-- from the tree does not reuse that buffer -- the open happens from the
-- neo-tree window, so Vim's "replace an empty unnamed buffer in place" rule
-- never applies -- and it lingers in `:ls`, the bufferline and `:bnext` for
-- the rest of the session, looking like a blank file that opened itself.
--
-- Only armed when the startup argument really was a directory, and it
-- disarms itself after the first real file, so buffers from a later `:enew`
-- are left alone.
local start_arg = vim.fn.argv(0)
if type(start_arg) == "string" and start_arg ~= "" then
  local stat = (vim.uv or vim.loop).fs_stat(start_arg)
  if stat and stat.type == "directory" then
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("ron_drop_startup_noname", { clear = true }),
      once = true,
      callback = function()
        -- Deferred: at BufReadPost the leftover may still own a window, and
        -- it is only safe to delete once something else has taken it over.
        vim.schedule(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if
              vim.bo[buf].buflisted
              and vim.bo[buf].buftype == ""
              and vim.api.nvim_buf_get_name(buf) == ""
              and not vim.bo[buf].modified
              and vim.api.nvim_buf_line_count(buf) == 1
              and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
              and #vim.fn.win_findbuf(buf) == 0
            then
              pcall(vim.api.nvim_buf_delete, buf, {})
            end
          end
        end)
      end,
    })
  end
end
