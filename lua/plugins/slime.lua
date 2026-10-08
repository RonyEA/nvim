-- vim-slime: send code from the buffer to a REPL running in tmux.
--
-- This is the single REPL path in this config. iron.nvim, molten-nvim and the
-- toggleterm radian/ipython floats were all dropped during the Omarchy
-- migration -- they duplicated this and collided on the <leader>r* prefix.
--
-- Usage: open the project with `dev` (or C-Space Space in tmux). That opens
-- this nvim in its own terminal window -- NOT inside tmux -- and a tmux session
-- whose `repl` window runs radian (R) or ipython (Python). Hyprland tiles the
-- two side by side, or they sit on different monitors. Then:
--   <leader>sl  current line     <leader>sp  paragraph     <leader>s;  selection
--   <leader>sc  pick a pane by hand (sticks for this buffer)
--
-- The target is found from nvim's cwd, so start nvim from the project root
-- (dev does). A relative target like ":repl" would NOT do: from outside tmux,
-- tmux resolves "current session" to whichever session was used last, which
-- can be a different project.

-- The session ~/.config/tmux/dev makes for a directory. Must match its
-- session_name(): lowercased basename, anything outside [a-z0-9_-] turned
-- into _, trailing _ dropped.
local function dev_session(dir)
  local name = vim.fs.basename(dir):lower():gsub("[^%w_-]", "_"):gsub("_+$", "")
  return name
end

-- Point this buffer at the project's repl window, unless it already has a
-- target (resolved earlier, or picked by hand with <leader>sc). With no such
-- session, leave it unset so slime prompts instead of sending somewhere wrong.
local function target_repl()
  if vim.b.slime_config then
    return
  end
  local target = "=" .. dev_session(vim.fn.getcwd()) .. ":repl"
  local found = vim.system({ "tmux", "display-message", "-p", "-t", target, "" }):wait().code == 0
  if found then
    vim.b.slime_config = { socket_name = "default", target_pane = target }
  else
    vim.notify("slime: no " .. target .. " (run `dev` in the project) -- pick a pane", vim.log.levels.WARN)
  end
end

-- expr + remap: resolve the target, then hand over to slime's <Plug> mapping.
local function send(plug)
  return function()
    target_repl()
    return plug
  end
end

return {
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "tmux"

      -- Send as-is, no extra escaping. Required for radian and IPython, which
      -- both do their own indentation handling.
      vim.g.slime_bracketed_paste = 1

      vim.g.slime_preserve_curpos = 1
    end,
    keys = {
      { "<leader>sl", send("<Plug>SlimeLineSend"), mode = "n", expr = true, remap = true, desc = "Slime send line" },
      { "<leader>sp", send("<Plug>SlimeParagraphSend"), mode = "n", expr = true, remap = true, desc = "Slime send paragraph" },
      { "<leader>s;", send("<Plug>SlimeRegionSend"), mode = "v", expr = true, remap = true, desc = "Slime send selection" },
      { "<leader>sc", "<cmd>SlimeConfig<cr>", mode = "n", desc = "Slime config (pick pane by hand)" },
    },
  },
}
