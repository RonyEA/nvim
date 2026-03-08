-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function lsp_attached(bufnr)
	local clients
	if vim.lsp.get_clients then
		clients = vim.lsp.get_clients({ bufnr = bufnr })
	else
		clients = vim.lsp.get_active_clients({ bufnr = bufnr })
	end
	return clients and #clients > 0
end

local function lsp_supports(bufnr, method)
	local clients
	if vim.lsp.get_clients then
		clients = vim.lsp.get_clients({ bufnr = bufnr })
	else
		clients = vim.lsp.get_active_clients({ bufnr = bufnr })
	end

	for _, client in ipairs(clients or {}) do
		if client.supports_method and client.supports_method(method) then
			return true
		end
	end

	return false
end

local function project_root()
	local ok, util = pcall(require, "lazyvim.util")
	if ok and util.root then
		return util.root()
	end
	return vim.loop.cwd()
end

local function python_analysis_profile(strict)
	local level = strict and "warning" or "none"
	local op_level = strict and "warning" or "none"
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
			reportOperatorIssue = op_level,
			reportAttributeAccessIssue = op_level,
		},
	}

	return {
		pyright = { python = { analysis = common } },
		basedpyright = { basedpyright = { analysis = common } },
	}
end

local function apply_python_diagnostic_mode(strict)
	local profiles = python_analysis_profile(strict)
	local changed = false

	for _, client in ipairs(vim.lsp.get_clients() or {}) do
		local settings = profiles[client.name]
		if settings then
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, settings)
			if client.supports_method and client.supports_method("workspace/didChangeConfiguration") then
				client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
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
end

vim.keymap.set("n", "<leader>sd", function()
	require("telescope.builtin").lsp_definitions()
end, { desc = "Symbol Definitions" })

vim.keymap.set("n", "<leader>si", function()
	if lsp_supports(0, "textDocument/implementation") then
		require("telescope.builtin").lsp_implementations()
		return
	end

	vim.notify("LSP has no implementation support here; using project grep fallback", vim.log.levels.INFO)
	require("telescope.builtin").grep_string({
		search = vim.fn.expand("<cword>"),
		cwd = project_root(),
		word_match = "-w",
	})
end, { desc = "Symbol Implementations" })

vim.keymap.set("n", "<leader>sr", function()
	if lsp_attached(0) then
		require("telescope.builtin").lsp_references({ include_declaration = true })
		return
	end

	-- Fallback when LSP is unavailable: project-wide word search.
	require("telescope.builtin").grep_string({
		search = vim.fn.expand("<cword>"),
		cwd = project_root(),
		word_match = "-w",
	})
end, { desc = "Symbol References (Project)" })

vim.keymap.set("n", "<leader>ss", function()
	require("telescope.builtin").lsp_document_symbols()
end, { desc = "Document Symbols" })

vim.keymap.set("n", "<leader>sS", function()
	require("telescope.builtin").lsp_workspace_symbols()
end, { desc = "Workspace Symbols" })

vim.keymap.set("n", "<leader>so", function()
	if lsp_supports(0, "textDocument/prepareCallHierarchy") and lsp_supports(0, "callHierarchy/outgoingCalls") then
		require("telescope.builtin").lsp_outgoing_calls()
		return
	end

	vim.notify("LSP call hierarchy not supported here", vim.log.levels.INFO)
end, { desc = "Outgoing Calls (Function Calls)" })

vim.keymap.set("n", "<leader>sI", function()
	if lsp_supports(0, "textDocument/prepareCallHierarchy") and lsp_supports(0, "callHierarchy/incomingCalls") then
		require("telescope.builtin").lsp_incoming_calls()
		return
	end

	vim.notify("LSP call hierarchy not supported here", vim.log.levels.INFO)
end, { desc = "Incoming Calls" })

vim.keymap.set("n", "<leader>uP", function()
	local strict = not vim.g.python_diagnostics_strict
	apply_python_diagnostic_mode(strict)
end, { desc = "Toggle Python Strict Diagnostics" })
