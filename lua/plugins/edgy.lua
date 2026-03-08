return {
  "folke/edgy.nvim",
  optional = true,
  opts = function(_, opts)
    local edgy_idx = LazyVim.plugin.extra_idx("ui.edgy")
    local symbols_idx = LazyVim.plugin.extra_idx("editor.outline")

    if edgy_idx and edgy_idx > symbols_idx then
      LazyVim.warn(
        "The `edgy.nvim` extra must be **imported** before the `outline.nvim` extra to work properly.",
        { title = "LazyVim" }
      )
    end

    opts.left = opts.left or {}
    table.insert(opts.left, {
      title = "Outline",
      ft = "Outline",
      pinned = true,
      open = "Outline",
      size = { height = 0.3 }, -- optional: adjust height as needed
    })
  end,
}
