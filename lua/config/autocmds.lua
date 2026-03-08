-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
local function activate_venv()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = buf ~= "" and vim.fs.dirname(buf) or vim.loop.cwd()

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

  -- Optional: make :!python use the venv too
  vim.g.python3_host_prog = venv .. "/bin/python"
end

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  callback = function()
    pcall(activate_venv)
  end,
})
