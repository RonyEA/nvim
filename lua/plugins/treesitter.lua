-- Parsers for the R / Quarto / Markdown workflow.
--
-- `rnoweb` covers .Rnw (Sweave). `markdown` + `markdown_inline` are what
-- quarto.lua registers for the `quarto` and `rmd` filetypes, so they must be
-- installed even though .qmd is not markdown.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "r",
        "rnoweb",
        "markdown",
        "markdown_inline",
        "yaml",
        "python",
        "bash",
        "sql",
      },
    },
  },

  -- Sticky parent context pinned to the top of the window.
  --
  -- The plugin itself is enabled by the ui.treesitter-context extra in
  -- lazyvim.json; only the line budget is changed here. LazyVim's own opts are
  -- `mode = "cursor", max_lines = 3`, which is sized for code -- three lines
  -- covers class -> method -> loop and nothing is lost.
  --
  -- JSON nests deeper than that, and there the parent keys are not context,
  -- they are the only thing saying what the value under the cursor MEANS: a
  -- bare `"enabled": false` tells you nothing without the six keys above it.
  -- Hence six. It costs no screen on ordinary code, because `mode = "cursor"`
  -- only ever draws as many lines as the cursor actually has ancestors.
  --
  -- `trim_scope` stays at its default of "outer", so when the nesting runs
  -- past the budget it is the OUTERMOST keys that get dropped, keeping the
  -- ones nearest the cursor -- the end that disambiguates.
  --
  -- The function form of `opts` is required, not stylistic: the extra declares
  -- its own `opts` as a function, and it is that function which registers the
  -- <leader>ut toggle. Taking the table form here would leave the two to be
  -- merged; this way the extra's function runs first and is handed its result
  -- to amend, so the toggle survives.
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = function(_, opts)
      opts.max_lines = 6
      return opts
    end,
  },
}
