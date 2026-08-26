-- Quarto (.qmd) support: LSP inside code chunks, plus chunk helpers.
--
-- Ported from RonyEA/nvim (lua/plugins/notebooks.lua) on 2026-08-26, with two
-- changes:
--
--   * codeRunner is now ENABLED and pointed at slime. In the old config it was
--     disabled because molten/iron/slime were all fighting over execution;
--     slime is the only runner left, so quarto can drive it directly.
--   * molten-nvim and jupytext.vim are gone along with the Jupyter path.
--
-- otter.nvim is what makes completion and diagnostics work INSIDE a ```{r} or
-- ```{python} chunk. It now feeds results through the native LSP client, so it
-- works with blink.cmp without a dedicated completion source.

return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown", "rmd" },
    init = function()
      vim.filetype.add({ extension = { qmd = "quarto" } })

      -- Register the markdown parser for quarto/rmd. Without this the R LSP
      -- does not attach inside .qmd chunks -- this was the fix in commit
      -- 196e5e1 "R LSP not working in .qmd".
      pcall(vim.treesitter.language.register, "markdown", "quarto")
      pcall(vim.treesitter.language.register, "markdown", "rmd")
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
        enabled = true,
        default_method = "slime",
      },
    },
    config = function(_, opts)
      require("quarto").setup(opts)

      local function insert_chunk(lang)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, row, row, false, {
          "```{" .. lang .. "}",
          "",
          "```",
        })
        vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
      end

      local function wrap_visual_chunk(lang)
        local srow = vim.fn.getpos("'<")[2] - 1
        local erow = vim.fn.getpos("'>")[2]
        vim.api.nvim_buf_set_lines(0, erow, erow, false, { "```" })
        vim.api.nvim_buf_set_lines(0, srow, srow, false, { "```{" .. lang .. "}" })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "rmd" },
        callback = function(ev)
          pcall(vim.cmd, "silent! QuartoActivate")

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end

          for key, lang in pairs({ r = "r", p = "python", b = "bash" }) do
            map("n", "<leader>qi" .. key, function()
              insert_chunk(lang)
            end, "Quarto: insert " .. lang .. " chunk")

            map("v", "<leader>qw" .. key, function()
              wrap_visual_chunk(lang)
            end, "Quarto: wrap selection in " .. lang .. " chunk")
          end
        end,
      })
    end,
    keys = {
      { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Quarto: preview" },
      { "<leader>qr", "<cmd>QuartoRender<cr>", desc = "Quarto: render" },
      { "<leader>qa", "<cmd>QuartoActivate<cr>", desc = "Quarto: activate" },
    },
  },
}
