return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      local needed = {
        "r",
        "markdown",
        "markdown_inline",
        "rnoweb",
        "yaml",
      }

      local have = {}
      for _, parser in ipairs(opts.ensure_installed) do
        have[parser] = true
      end

      for _, parser in ipairs(needed) do
        if not have[parser] then
          table.insert(opts.ensure_installed, parser)
        end
      end
    end,
  },
}
