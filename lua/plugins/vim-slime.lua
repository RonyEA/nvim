return {
  {
    "jpalardy/vim-slime",
    enabled = true,
    init = function()
      -- Use tmux
      vim.g.slime_target = "tmux"

      -- Send as-is (no extra escaping)
      vim.g.slime_bracketed_paste = 1

      -- Don't prompt every time
      vim.g.slime_default_config = {
        socket_name = "default",
        target_pane = "{last}",
      }

      -- Optional: keep cursor position after sending
      vim.g.slime_preserve_curpos = 1

      -- Optional: send to a tmux pane even if you're not inside tmux
      -- (Works when Neovim runs inside tmux or can talk to tmux)
    end,
    keys = {
      -- Visual mode: send selection
      { "<leader>ss", "<Plug>SlimeRegionSend", mode = "v", desc = "Slime send selection" },
      -- Normal mode: send current line
      { "<leader>sl", "<Plug>SlimeLineSend", mode = "n", desc = "Slime send line" },
      -- Normal mode: send paragraph
      { "<leader>sp", "<Plug>SlimeParagraphSend", mode = "n", desc = "Slime send paragraph" },
      -- Configure target pane (run once)
      { "<leader>sc", ":SlimeConfig<CR>", desc = "Slime config" },
    },
  },
}
