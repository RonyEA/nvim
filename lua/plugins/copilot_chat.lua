return {
  "CopilotC-Nvim/CopilotChat.nvim",
  event = "VeryLazy",
  build = "make tiktoken",
  dependencies = {
    "zbirenbaum/copilot.lua",
    "nvim-lua/plenary.nvim",
  },
  opts = {
    temperature = 0.1,
    auto_insert_mode = true,
    show_help = false,
    window = {
      layout = "vertical",
      width = 0.45,
    },

    -- Default resources and tools for every ask.
    resources = { "selection" },
    tools = "copilot",

    -- Instruction files are added automatically when found in project root.
    instruction_files = {
      ".github/copilot-instructions.md",
      "AGENTS.md",
    },

    -- Avoid sticky resources that can fail in non-git or detached contexts.
    sticky = nil,

    prompts = {
      WorkspaceAudit = {
        prompt = table.concat({
          "@copilot Build an accurate understanding of this repository before answering.",
          "First inspect the workspace with tools in this order:",
          "1) Use glob to discover structure.",
          "2) Use grep to find relevant symbols/config.",
          "3) Use file to read key files.",
          "Then provide your answer based on those findings.",
          "If the question references a specific function, include file path and line hints in your response.",
          "If context is still insufficient, ask for one concrete file/symbol instead of guessing.",
        }, "\n"),
        description = "Agentic workspace-first analysis",
      },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>CopilotChat<cr>", desc = "Open Copilot Chat" },
    {
      "<leader>aA",
      function()
        require("CopilotChat").ask(
          table.concat({
            "@copilot Use workspace tools before answering.",
            "Start by mapping the project with #glob:**/* and then read the relevant files.",
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
      desc = "Workspace Audit Prompt",
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
