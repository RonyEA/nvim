return {
  -- Curated theme set (fast, well-maintained, good syntax contrast).
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "Mofiqul/vscode.nvim", lazy = true },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nordfox",
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>ut",
        function()
          require("telescope.builtin").colorscheme({
            enable_preview = true,
          })
        end,
        desc = "Pick Theme",
      },
    },
  },
}
