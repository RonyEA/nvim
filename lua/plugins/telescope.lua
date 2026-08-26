-- Telescope, ported from RonyEA/nvim on 2026-08-26.
--
-- Omarchy's LazyVim uses snacks.nvim pickers. This adds Telescope alongside it
-- and takes over the <leader>f* / <leader>g* keys, because that is the muscle
-- memory being migrated. The snacks pickers stay available under their own
-- LazyVim defaults.
--
-- Changed from the original: kkharji/sqlite.lua is no longer listed as a
-- frecency dependency -- current telescope-frecency uses its own storage and
-- does not need it. Every extension load is pcall-guarded, so if frecency
-- fails <leader>ff silently falls back to plain find_files.

-- LazyVim's root detection. The original called require("lazyvim.util").root(),
-- which is the pre-LazyVim-global API; this tries the current one first.
local function root()
  if _G.LazyVim and _G.LazyVim.root then
    return _G.LazyVim.root()
  end
  local ok, util = pcall(require, "lazyvim.util")
  if ok and util.root then
    return util.root()
  end
  return vim.uv.cwd()
end

return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-frecency.nvim",
  },
  keys = {
    {
      "<leader>fp",
      function()
        require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
      end,
      desc = "Find Plugin File",
    },
    {
      "<leader>fP",
      function()
        require("telescope.builtin").find_files({ cwd = root(), hidden = true })
      end,
      desc = "Find Project File (Root)",
    },
    {
      "<leader>gP",
      function()
        require("telescope.builtin").live_grep({ cwd = root() })
      end,
      desc = "Grep Project (Root)",
    },
    {
      "<leader>ff",
      function()
        local ok = pcall(require("telescope").extensions.frecency.frecency, {
          workspace = "CWD",
          prompt_title = "Smart Files (Recent + Frequent)",
        })
        if not ok then
          require("telescope.builtin").find_files({ hidden = true })
        end
      end,
      desc = "Find Files (Smart)",
    },
    {
      "<leader>fR",
      function()
        require("telescope").extensions.frecency.frecency({
          workspace = "CWD",
          prompt_title = "Recent + Frequent Files",
        })
      end,
      desc = "Recent/Frequent Files",
    },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    {
      "<leader>fo",
      function()
        require("telescope.builtin").oldfiles({ cwd_only = true })
      end,
      desc = "Recent Files (Project)",
    },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
  },
  opts = function(_, opts)
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")

    opts.defaults = opts.defaults or {}
    opts.defaults.layout_strategy = "horizontal"
    opts.defaults.layout_config = vim.tbl_deep_extend("force", opts.defaults.layout_config or {}, {
      prompt_position = "top",
    })
    opts.defaults.sorting_strategy = "ascending"
    opts.defaults.winblend = 0

    opts.defaults.mappings = opts.defaults.mappings or {}
    for _, mode in ipairs({ "i", "n" }) do
      opts.defaults.mappings[mode] = vim.tbl_extend("force", opts.defaults.mappings[mode] or {}, {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      })
    end

    -- Data-science noise: caches, virtualenvs, renv libraries, and the
    -- data/output directories that make a grep useless.
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
    opts.extensions.fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
    opts.extensions.frecency = {
      show_scores = true,
      show_unindexed = true,
      ignore_patterns = { "*.git/*", "*/tmp/*" },
      default_workspace = "CWD",
      workspaces = { CWD = (vim.uv or vim.loop).cwd() },
    }
    opts.extensions["ui-select"] = themes.get_dropdown({
      previewer = false,
      layout_config = { width = 0.5 },
    })

    return opts
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    pcall(require("telescope").load_extension, "ui-select")
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "frecency")
  end,
}
