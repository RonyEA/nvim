local claude_term

local function ensure_claude_term()
  if claude_term then
    return claude_term
  end

  local ok, toggleterm = pcall(require, "toggleterm.terminal")
  if not ok then
    return nil
  end

  claude_term = toggleterm.Terminal:new({
    cmd = "claude",
    direction = "float",
    hidden = true,
    close_on_exit = false,
    float_opts = { border = "rounded" },
    on_open = function()
      vim.cmd("startinsert!")
    end,
  })

  return claude_term
end

local function open_claude(dir)
  if vim.fn.executable("claude") ~= 1 then
    vim.notify("claude CLI not found in PATH", vim.log.levels.ERROR)
    return
  end

  local term = ensure_claude_term()
  if not term then
    vim.notify("toggleterm.nvim is not available", vim.log.levels.ERROR)
    return
  end

  term.dir = dir or vim.fn.getcwd()
  term:toggle()
end

return {
  {
    "akinsho/toggleterm.nvim",
    opts = function(_, opts)
      pcall(vim.api.nvim_del_user_command, "ClaudeCode")
      vim.api.nvim_create_user_command("ClaudeCode", function(command_opts)
        local dir = command_opts.args ~= "" and vim.fn.fnamemodify(command_opts.args, ":p") or vim.fn.getcwd()
        open_claude(dir)
      end, {
        nargs = "?",
        complete = "dir",
        desc = "Open Claude Code in a floating terminal",
      })

      return opts
    end,
    keys = {
      {
        "<leader>ac",
        function()
          open_claude(vim.fn.getcwd())
        end,
        desc = "Claude Code",
      },
    },
  },
}