-- Obsidian vault integration.
--
-- Ported from RonyEA/nvim on 2026-08-26 with two changes for this setup:
--   * completion switched from nvim-cmp to blink.cmp
--   * ui.enable = false, so render-markdown.nvim (from LazyVim's lang.markdown
--     extra) owns concealing. With both enabled they fight over the same
--     buffers and produce flickering / doubled checkbox and bullet icons.

local function path_exists(path)
  return (vim.uv or vim.loop).fs_stat(vim.fn.expand(path)) ~= nil
end

local function build_workspaces()
  local candidates = {
    { name = "personal", path = "~/Obsidian" },
    { name = "notes", path = "~/Documents/Obsidian" },
    { name = "vault", path = "~/vault" },
    { name = "main", path = "~/vaults/main" },
    { name = "StockAppNotes", path = "~/Projects/stockAnalysis" },
  }

  local workspaces = {}

  local env_vault = vim.env.OBSIDIAN_VAULT
  if env_vault and env_vault ~= "" and path_exists(env_vault) then
    table.insert(workspaces, { name = "env", path = vim.fn.expand(env_vault) })
  end

  for _, ws in ipairs(candidates) do
    if path_exists(ws.path) then
      table.insert(workspaces, { name = ws.name, path = vim.fn.expand(ws.path) })
    end
  end

  -- Nothing found: fall back to cwd so the plugin still loads rather than
  -- erroring on an empty workspace list.
  if #workspaces == 0 then
    table.insert(workspaces, { name = "cwd", path = vim.fn.getcwd() })
  end

  return workspaces
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>on", "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian: quick switch" },
    { "<leader>of", "<cmd>ObsidianSearch<cr>", desc = "Obsidian: search notes" },
    { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Obsidian: tags" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian: backlinks" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Obsidian: links in note" },
    { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Obsidian: today note" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Obsidian: yesterday note" },
    { "<leader>oT", "<cmd>ObsidianTomorrow<cr>", desc = "Obsidian: tomorrow note" },
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Obsidian: open in app" },
    { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Obsidian: rename note" },
    { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Obsidian: paste image" },
  },
  opts = {
    workspaces = build_workspaces(),

    daily_notes = {
      folder = "daily",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      template = "daily.md",
    },

    -- blink.cmp, not nvim-cmp. The old config used nvim_cmp = true via the
    -- coding.nvim-cmp extra, which is not enabled here.
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
    },

    new_notes_location = "notes_subdir",
    notes_subdir = "inbox",

    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {},
    },

    preferred_link_style = "wiki",
    disable_frontmatter = false,

    note_id_func = function(title)
      if title ~= nil then
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      end
      return tostring(os.time())
    end,

    -- Off on purpose: render-markdown.nvim handles all of this.
    ui = { enable = false },

    picker = { name = "telescope.nvim" },

    attachments = { img_folder = "assets/imgs" },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    if opts.workspaces and #opts.workspaces > 0 and opts.workspaces[1].name == "cwd" then
      vim.schedule(function()
        vim.notify(
          "Obsidian vault not detected. Using current working directory as workspace.",
          vim.log.levels.INFO
        )
      end)
    end
  end,
}
