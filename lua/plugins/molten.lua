return {
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    ft = { "python", "markdown", "quarto", "r", "rmd" },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "none"
      vim.g.molten_wrap_output = true
    end,
  },
}
