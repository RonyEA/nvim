return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown", "rmd" },
    init = function()
      vim.filetype.add({
        extension = {
          qmd = "quarto",
        },
      })
    end,
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "r", "python", "bash" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
      },
      codeRunner = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("quarto").setup(opts)
    end,
    keys = {
      { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Quarto: preview" },
      { "<leader>qr", "<cmd>QuartoRender<cr>", desc = "Quarto: render" },
      { "<leader>qa", "<cmd>QuartoActivate<cr>", desc = "Quarto: activate" },
    },
  },

  {
    "goerz/jupytext.vim",
    event = { "BufReadPre *.ipynb", "BufNewFile *.ipynb" },
    init = function()
      -- Open notebooks in a script-friendly format for editing + execution in Neovim.
      vim.g.jupytext_fmt = "py:percent"
    end,
  },

  {
    "benlubas/molten-nvim",
    keys = {
      { "<leader>mj", "<cmd>MoltenInit<cr>", desc = "Notebook: init kernel" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", desc = "Notebook: eval line" },
      { "<leader>mv", "<cmd>MoltenEvaluateVisual<cr>", mode = "v", desc = "Notebook: eval selection" },
      { "<leader>mo", "<cmd>MoltenOpenOutput<cr>", desc = "Notebook: open output" },
      { "<leader>mx", "<cmd>MoltenInterrupt<cr>", desc = "Notebook: interrupt" },
    },
  },
}
