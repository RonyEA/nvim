return {
  -- Curated theme set (fast, well-maintained, good syntax contrast).
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    opts = {
      options = {
        transparent = true,
      },
    },
  },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "Mofiqul/vscode.nvim", lazy = true },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000, -- load before other plugins so highlights are set first
    opts = {
      flavour = "mocha",
      background = { dark = "mocha" },
      -- The terminal already paints a Catppuccin background, so letting it
      -- show through keeps nvim and the surrounding shell visually seamless.
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        neotree = true,
        treesitter = true,
        telescope = { enabled = true },
        which_key = true,
        dap = true,
        dap_ui = true,
        mason = true,
        noice = true,
        notify = true,
        lsp_trouble = true,
        illuminate = true,
        native_lsp = {
          enabled = true,
          -- Undercurl now actually renders: tmux advertises `usstyle`.
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
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
