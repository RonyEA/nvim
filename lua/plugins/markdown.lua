-- Markdown: browser preview on top of what LazyVim's lang.markdown extra
-- already provides (marksman LSP, markdownlint-cli2, render-markdown.nvim).
--
-- render-markdown.nvim does the in-buffer rendering -- headings, tables, code
-- blocks, checkboxes and callouts drawn live as you edit. It is deliberately
-- left at the extra's defaults; see lua/config/autocmds.lua for the one place
-- it is suppressed (quarto/rmd, where the ```{r} fences must stay literal).

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      -- The plugin's own installer. Needs node, which mise provides here.
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_theme = "dark"
      -- Do not steal focus from the editor when the preview opens.
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_open_to_the_world = 0
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview (browser)" },
    },
  },
}
