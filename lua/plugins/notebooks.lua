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

      -- Use markdown parser for quarto/rmd so syntax highlighting works reliably.
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
        enabled = false,
      },
    },
    config = function(_, opts)
      require("quarto").setup(opts)

      local function insert_chunk(lang)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local lines = {
          "```{" .. lang .. "}",
          "",
          "```",
        }
        vim.api.nvim_buf_set_lines(0, row, row, false, lines)
        vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
      end

      local function wrap_visual_chunk(lang)
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local srow = start_pos[2] - 1
        local erow = end_pos[2]

        vim.api.nvim_buf_set_lines(0, erow, erow, false, { "```" })
        vim.api.nvim_buf_set_lines(0, srow, srow, false, { "```{" .. lang .. "}" })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "rmd" },
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end

          map("n", "<leader>qir", function()
            insert_chunk("r")
          end, "Quarto: insert R chunk")

          map("n", "<leader>qip", function()
            insert_chunk("python")
          end, "Quarto: insert Python chunk")

          map("n", "<leader>qib", function()
            insert_chunk("bash")
          end, "Quarto: insert Bash chunk")

          map("v", "<leader>qwr", function()
            wrap_visual_chunk("r")
          end, "Quarto: wrap selection in R chunk")

          map("v", "<leader>qwp", function()
            wrap_visual_chunk("python")
          end, "Quarto: wrap selection in Python chunk")

          map("v", "<leader>qwb", function()
            wrap_visual_chunk("bash")
          end, "Quarto: wrap selection in Bash chunk")
        end,
      })
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
