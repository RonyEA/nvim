-- Keymaps are automatically loaded on the VeryLazy event.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- Ported from RonyEA/nvim on 2026-08-26.
--
-- NOTE: <leader>sd, <leader>sr and <leader>ss deliberately shadow LazyVim's
-- search-diagnostics / grug-far-replace / goto-symbol maps. That was the
-- original config's choice and is kept. The <leader>s* prefix is also shared
-- with vim-slime (<leader>sl, sp, s;, sc) -- see lua/plugins/slime.lua.

local function lsp_clients(bufnr)
  if vim.lsp.get_clients then
    return vim.lsp.get_clients({ bufnr = bufnr })
  end
  return vim.lsp.get_active_clients({ bufnr = bufnr })
end

local function lsp_attached(bufnr)
  local clients = lsp_clients(bufnr)
  return clients and #clients > 0
end

-- Neovim 0.11 moved supports_method to a method call; 0.12 still accepts the
-- dot form but warns. Try the method first, fall back for older clients.
local function client_supports(client, method)
  if type(client.supports_method) ~= "function" then
    return false
  end
  local ok, res = pcall(function()
    return client:supports_method(method)
  end)
  if ok then
    return res
  end
  local ok2, res2 = pcall(client.supports_method, method)
  return ok2 and res2 or false
end

local function lsp_supports(bufnr, method)
  for _, client in ipairs(lsp_clients(bufnr) or {}) do
    if client_supports(client, method) then
      return true
    end
  end
  return false
end

local function project_root()
  if _G.LazyVim and _G.LazyVim.root then
    return _G.LazyVim.root()
  end
  local ok, util = pcall(require, "lazyvim.util")
  if ok and util.root then
    return util.root()
  end
  return (vim.uv or vim.loop).cwd()
end

local function grep_fallback()
  require("telescope.builtin").grep_string({
    search = vim.fn.expand("<cword>"),
    cwd = project_root(),
    word_match = "-w",
  })
end

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map("<leader>sd", function()
  require("telescope.builtin").lsp_definitions()
end, "Symbol Definitions")

map("<leader>si", function()
  if lsp_supports(0, "textDocument/implementation") then
    require("telescope.builtin").lsp_implementations()
    return
  end
  vim.notify("LSP has no implementation support here; using project grep fallback", vim.log.levels.INFO)
  grep_fallback()
end, "Symbol Implementations")

map("<leader>sr", function()
  if lsp_attached(0) then
    require("telescope.builtin").lsp_references({ include_declaration = true })
    return
  end
  grep_fallback()
end, "Symbol References (Project)")

map("<leader>ss", function()
  require("telescope.builtin").lsp_document_symbols()
end, "Document Symbols")

map("<leader>sS", function()
  require("telescope.builtin").lsp_workspace_symbols()
end, "Workspace Symbols")

map("<leader>so", function()
  if lsp_supports(0, "textDocument/prepareCallHierarchy") and lsp_supports(0, "callHierarchy/outgoingCalls") then
    require("telescope.builtin").lsp_outgoing_calls()
    return
  end
  vim.notify("LSP call hierarchy not supported here", vim.log.levels.INFO)
end, "Outgoing Calls")

map("<leader>sI", function()
  if lsp_supports(0, "textDocument/prepareCallHierarchy") and lsp_supports(0, "callHierarchy/incomingCalls") then
    require("telescope.builtin").lsp_incoming_calls()
    return
  end
  vim.notify("LSP call hierarchy not supported here", vim.log.levels.INFO)
end, "Incoming Calls")

-- Toggle basedpyright between the relaxed profile set in lua/plugins/lsp.lua
-- and a strict workspace-wide one, live, without restarting the server.
local function python_analysis_profile(strict)
  local level = strict and "warning" or "none"
  local common = {
    diagnosticMode = strict and "workspace" or "openFilesOnly",
    typeCheckingMode = strict and "standard" or "basic",
    autoSearchPaths = true,
    useLibraryCodeForTypes = true,
    diagnosticSeverityOverrides = {
      reportMissingTypeStubs = strict and "warning" or "none",
      reportUnknownVariableType = level,
      reportUnknownMemberType = level,
      reportUnknownArgumentType = level,
      reportUnknownParameterType = level,
      reportUnknownLambdaType = level,
      reportOperatorIssue = level,
      reportAttributeAccessIssue = level,
    },
  }

  return {
    pyright = { python = { analysis = common } },
    basedpyright = { basedpyright = { analysis = common } },
  }
end

map("<leader>uP", function()
  local strict = not vim.g.python_diagnostics_strict
  local profiles = python_analysis_profile(strict)
  local changed = false

  for _, client in ipairs(vim.lsp.get_clients() or {}) do
    local settings = profiles[client.name]
    if settings then
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, settings)
      if client_supports(client, "workspace/didChangeConfiguration") then
        client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
      changed = true
    end
  end

  if not changed then
    vim.notify("No active pyright/basedpyright client in this buffer", vim.log.levels.INFO)
    return
  end

  vim.g.python_diagnostics_strict = strict
  vim.notify(strict and "Python strict diagnostics: ON" or "Python strict diagnostics: OFF", vim.log.levels.INFO)
end, "Toggle Python Strict Diagnostics")
