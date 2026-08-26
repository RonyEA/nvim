-- vim-slime: send code from the buffer to a REPL running in a tmux pane.
--
-- This is the single REPL path in this config. iron.nvim, molten-nvim and the
-- toggleterm radian/ipython floats were all dropped during the Omarchy
-- migration -- they duplicated this and collided on the <leader>r* prefix.
--
-- Usage: start tmux, run `radian` (R) or `ipython` (Python) in another pane,
-- then <leader>sc ONCE per session to pick that pane. After that <leader>sl
-- sends the current line, <leader>sp the paragraph, <leader>s; a selection.
--
-- Note: slime only works when Neovim itself is running inside tmux. Outside
-- tmux it fails quietly.

return {
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "tmux"

      -- Send as-is, no extra escaping. Required for radian and IPython, which
      -- both do their own indentation handling.
      vim.g.slime_bracketed_paste = 1

      -- Default to the last-used pane so <leader>sc is a confirmation rather
      -- than a full prompt.
      vim.g.slime_default_config = {
        socket_name = "default",
        target_pane = "{last}",
      }

      vim.g.slime_preserve_curpos = 1
    end,
    keys = {
      { "<leader>sl", "<Plug>SlimeLineSend", mode = "n", desc = "Slime send line" },
      { "<leader>sp", "<Plug>SlimeParagraphSend", mode = "n", desc = "Slime send paragraph" },
      { "<leader>s;", "<Plug>SlimeRegionSend", mode = "v", desc = "Slime send selection" },
      { "<leader>sc", "<cmd>SlimeConfig<cr>", mode = "n", desc = "Slime config (pick pane)" },
    },
  },
}
