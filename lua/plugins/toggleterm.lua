return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      -- A single keystroke you’ll actually use:
      open_mapping = [[<leader>tt]],
      direction = "float",
      float_opts = { border = "rounded" },
      shade_terminals = false,
    },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (horizontal)" },
    },
  },
}
