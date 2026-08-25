return {
  "CopilotC-Nvim/CopilotChat.nvim",
  event = "VeryLazy",
  build = "make tiktoken",
  dependencies = {
    "zbirenbaum/copilot.lua",
    "nvim-lua/plenary.nvim",
  },
  opts = {
    model = "auto",
    temperature = 0.1,
    auto_insert_mode = true,
    show_help = false,
    window = {
      layout = "vertical",
      width = 0.45,
    },

    -- Default resources and tools for every ask.
    -- buffer: always attach the current file so plain questions have local context.
    -- selection: attach visual selection when present.
    -- diagnostics: attach LSP errors/warnings so "fix this" works without manual pinning.
    resources = { "buffer", "selection", "diagnostics" },
    tools = "copilot",

    -- Instruction files are added automatically when found in project root.
    -- Prefer the project brief first so asks start from repo-specific context.
    instruction_files = {
      "CLUADE.md",
      "CLAUDE.md",
      ".github/copilot-instructions.md",
      "AGENTS.md",
    },

    -- Avoid sticky resources that can fail in non-git or detached contexts.
    sticky = nil,

    prompts = {
      -- Lightweight preamble: scoped globs, grep only on relevant files.
      -- Use this for most questions; cheaper than DeepAudit.
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

      -- Full repo scan: use only for broad architectural or cross-cutting questions.
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
      "<leader>aA",
      function()
        require("CopilotChat").ask(
          table.concat({
            "@copilot Use workspace tools before answering.",
            "Read CLAUDE.md first when present and use it as the project brief.",
            "Start with: glob *.{md,py,R,r,ipynb,qmd,rmd,lua,json,toml,yaml,yml} for root files, then glob **/*.{py,R,r,ipynb,qmd,rmd,lua} for source.",
            "Then grep only files relevant to the question.",
            "Do not infer implementation details from file names alone.",
          }, "\n")
        )
      end,
      desc = "Agent Ask (Project-Aware)",
    },
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
          require("CopilotChat").ask(
            table.concat({
              "/WorkspaceAudit",
              input,
            }, "\n\n")
          )
        end)
      end,
      desc = "Ask + Workspace Audit",
    },
    -- Ask about all files currently open in splits/buffers.
    -- No workspace scan: injects #file: refs directly, then prompts for question.
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
          require("CopilotChat").ask(
            table.concat(refs, " ") .. "\n\n" .. input
          )
        end)
      end,
      desc = "Ask About All Open Buffers",
    },
    { "<leader>cq", "<cmd>CopilotChatExplain<cr>", mode = "v", desc = "Explain selection" },
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
    { "<leader>cr", "<cmd>CopilotChatReview<cr>", mode = "v", desc = "Review selection" },
    { "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = "v", desc = "Fix selection" },
  },
}
