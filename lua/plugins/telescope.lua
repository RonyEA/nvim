return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  keys = {
    -- Plugin files
    {
      "<leader>fp",
      function()
        require("telescope.builtin").find_files({
          cwd = require("lazy.core.config").options.root,
        })
      end,
      desc = "Find Plugin File",
    },

    -- Project root files
    {
      "<leader>fP",
      function()
        require("telescope.builtin").find_files({
          cwd = require("lazyvim.util").root(),
          hidden = true,
        })
      end,
      desc = "Find Project File (Root)",
    },

    -- Project root grep
    {
      "<leader>gP",
      function()
        require("telescope.builtin").live_grep({
          cwd = require("lazyvim.util").root(),
        })
      end,
      desc = "Grep Project (Root)",
    },

    -- Standard Telescope pickers
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
  },
  opts = function(_, opts)
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")
    opts.defaults = opts.defaults or {}

    -- UI / layout
    opts.defaults.layout_strategy = "horizontal"
    opts.defaults.layout_config = vim.tbl_deep_extend("force", opts.defaults.layout_config or {}, {
      prompt_position = "top",
    })
    opts.defaults.sorting_strategy = "ascending"
    opts.defaults.winblend = 0

    -- Key mappings
    opts.defaults.mappings = opts.defaults.mappings or {}
    opts.defaults.mappings.i = vim.tbl_extend("force", opts.defaults.mappings.i or {}, {
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
    })
    opts.defaults.mappings.n = vim.tbl_extend("force", opts.defaults.mappings.n or {}, {
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
    })

    -- Ignore patterns
    opts.defaults.file_ignore_patterns = vim.list_extend(opts.defaults.file_ignore_patterns or {}, {
      "venv/",
      "%.venv/",
      "__pycache__/",
      "%.pytest_cache/",
      "%.mypy_cache/",
      "%.ruff_cache/",
      "%.ipynb_checkpoints/",
      "renv/library/",
      "%.Rproj%.user/",
      "%.Rhistory",
      "%.RData",
      "%.git/",
      "node_modules/",
      "data/",
      "Data/",
      "outputs?/",
      "results?/",
    })

    -- Ripgrep arguments
    opts.defaults.vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--glob=!.git/",
      "--glob=!venv/**",
      "--glob=!.venv/**",
      "--glob=!renv/library/**",
      "--glob=!__pycache__/**",
      "--glob=!.Rproj.user/**",
      "--glob=!.pytest_cache/**",
      "--glob=!.mypy_cache/**",
      "--glob=!.ruff_cache/**",
      "--glob=!.ipynb_checkpoints/**",
    }

    opts.extensions = opts.extensions or {}
    opts.extensions["ui-select"] = themes.get_dropdown({
      previewer = false,
      layout_config = {
        width = 0.5,
      },
    })

    return opts
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    pcall(require("telescope").load_extension, "ui-select")
  end,
}
