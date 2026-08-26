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
}
