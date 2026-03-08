return {
  {
    "R-nvim/R.nvim",
    ft = { "r", "rmd", "quarto" },
    dependencies = {
      "R-nvim/cmp-r",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",
    },
    opts = {
      R_args = { "--quiet", "--no-save" },
      auto_start = "no",
      objbr_auto_start = false,
    },
    config = function(_, opts)
      require("r").setup(opts)
    end,
    keys = {
      { "<leader>rR", "<cmd>RStart<cr>", desc = "R: start" },
      { "<leader>rQ", "<cmd>RStop<cr>", desc = "R: stop" },
    },
  },
}
