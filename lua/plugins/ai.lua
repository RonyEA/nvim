-- AI tooling, ported from RonyEA/nvim on 2026-08-26.
--
-- LazyVim's ai.copilot and ai.copilot-chat extras provide copilot.lua and
-- CopilotChat.nvim; this layers on the custom audit prompts and keys, plus the
-- hand-rolled Claude Code terminal (which was never a plugin -- just a
-- toggleterm float running the `claude` CLI).
--
-- KEYMAP WARNING: <leader>cf (visual, CopilotChatFix) shadows LazyVim's format
-- keymap. That is inherited from the original config. Because Omarchy sets
-- vim.g.autoformat = false, manual format matters more here than it did
-- before -- rename this to <leader>cF if you want format back.

local claude_term

local function open_claude(dir)
  if vim.fn.executable("claude") ~= 1 then
    vim.notify("claude CLI not found in PATH", vim.log.levels.ERROR)
    return
  end

  if not claude_term then
    local ok, toggleterm = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.notify("toggleterm.nvim is not available", vim.log.levels.ERROR)
      return
    end
    claude_term = toggleterm.Terminal:new({
      cmd = "claude",
      direction = "float",
      hidden = true,
      close_on_exit = false,
      float_opts = { border = "rounded" },
      on_open = function()
        vim.cmd("startinsert!")
      end,
    })
  end

  claude_term.dir = dir or vim.fn.getcwd()
  claude_term:toggle()
end

return {
  -- Inline ghost-text suggestions off; panel kept. The original config found
  -- inline suggestions too noisy alongside blink.cmp's own menu.
  {
    "zbirenbaum/copilot.lua",
    optional = true,
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = true },
    },
  },

  {
    "akinsho/toggleterm.nvim",
    opts = function(_, opts)
      pcall(vim.api.nvim_del_user_command, "ClaudeCode")
      vim.api.nvim_create_user_command("ClaudeCode", function(command_opts)
        local dir = command_opts.args ~= "" and vim.fn.fnamemodify(command_opts.args, ":p") or vim.fn.getcwd()
        open_claude(dir)
      end, {
        nargs = "?",
        complete = "dir",
        desc = "Open Claude Code in a floating terminal",
      })
      return opts
    end,
    keys = {
      {
        "<leader>ac",
        function()
          open_claude(vim.fn.getcwd())
        end,
        desc = "Claude Code",
      },
    },
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    optional = true,
    opts = {
      model = "auto",
      temperature = 0.1,
      auto_insert_mode = true,
      show_help = false,
      window = { layout = "vertical", width = 0.45 },

      -- Attach the current buffer, any visual selection, and LSP diagnostics to
      -- every ask, so "fix this" works without manually pinning context.
      resources = { "buffer", "selection", "diagnostics" },
      tools = "copilot",

      instruction_files = {
        "CLAUDE.md",
        ".github/copilot-instructions.md",
        "AGENTS.md",
      },

      sticky = nil,

      prompts = {
        -- Scoped inspection. Cheaper than DeepAudit; use for most questions.
        WorkspaceAudit = {
          prompt = table.concat({
            "@copilot Inspect this project before answering using these ordered steps:",
            "0) Read CLAUDE.md first when present; treat it as the project brief.",
            "1) glob *.{md,py,R,r,ipynb,qmd,rmd,lua,json,toml,yaml,yml} — read root project files and manifests.",
            "2) glob **/*.{py,R,r,ipynb,qmd,rmd,lua} — map the source tree, prioritizing the languages used in this project.",
            "3) grep — only on files relevant to the question; do not scan the whole repo.",
            "4) file — read only files directly referenced or clearly relevant to the question.",
            "After these steps, answer with what you have.",
            "Only call more tools if a specific symbol or file in the question has not yet been read.",
            "Always cite file paths and line numbers in your response.",
            "Never infer implementation details from file names alone.",
          }, "\n"),
          description = "Scoped workspace inspection before answering (default)",
        },

        -- Full repo scan. Broad architectural questions only.
        DeepAudit = {
          prompt = table.concat({
            "@copilot Build a thorough understanding of this repository before answering.",
            "0) Read CLAUDE.md first when present; treat it as the project brief.",
            "1) glob **/* to enumerate all files.",
            "2) grep for all relevant symbols and patterns across the repo.",
            "3) file — read every file that is directly relevant.",
            "Provide a complete answer with file paths and line numbers.",
            "Ask for a concrete file or symbol only if context is still insufficient after the above.",
          }, "\n"),
          description = "Full repo scan — use for architectural/cross-cutting questions",
        },
      },
    },
    keys = {
      { "<leader>aa", "<cmd>CopilotChat<cr>", desc = "Open Copilot Chat" },
      { "<leader>am", "<cmd>CopilotChatModels<cr>", desc = "Select Copilot Model" },
      {
        "<leader>aw",
        function()
          require("CopilotChat").ask("/WorkspaceAudit")
        end,
        desc = "Workspace Audit (Scoped)",
      },
      {
        "<leader>aD",
        function()
          require("CopilotChat").ask("/DeepAudit")
        end,
        desc = "Deep Audit (Full Repo Scan)",
      },
      {
        "<leader>aW",
        function()
          vim.ui.input({ prompt = "Ask with workspace audit: " }, function(input)
            if not input or vim.trim(input) == "" then
              return
            end
            require("CopilotChat").ask("/WorkspaceAudit\n\n" .. input)
          end)
        end,
        desc = "Ask + Workspace Audit",
      },
      {
        "<leader>aB",
        function()
          local refs = {}
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
              local path = vim.api.nvim_buf_get_name(buf)
              if path ~= "" and not path:match("^%a+://") then
                table.insert(refs, "#file:" .. vim.fn.fnamemodify(path, ":~:."))
              end
            end
          end
          if #refs == 0 then
            vim.notify("No file buffers open", vim.log.levels.WARN)
            return
          end
          vim.ui.input({ prompt = "Ask about open buffers (" .. #refs .. " files): " }, function(input)
            if not input or vim.trim(input) == "" then
              return
            end
            require("CopilotChat").ask(table.concat(refs, " ") .. "\n\n" .. input)
          end)
        end,
        desc = "Ask About All Open Buffers",
      },
      {
        "<leader>ce",
        function()
          local file = vim.fn.expand("%:p")
          if file == "" then
            vim.notify("No file in current window", vim.log.levels.WARN)
            return
          end
          require("CopilotChat").ask(
            table.concat({
              "@copilot Explain the function under cursor in detail.",
              "Use this file as source of truth:",
              "#file:" .. file,
            }, "\n")
          )
        end,
        desc = "Explain Function (Current File)",
      },
      { "<leader>cq", "<cmd>CopilotChatExplain<cr>", mode = "v", desc = "Explain selection" },
      { "<leader>cr", "<cmd>CopilotChatReview<cr>", mode = "v", desc = "Review selection" },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = "v", desc = "Fix selection" },
    },
  },
}
