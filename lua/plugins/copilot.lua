return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter", -- Lazy load on first insert for faster startup
  opts = {
    suggestion = {
      -- Inline ghost text is off; using CopilotChat chat-first workflow instead.
      -- To re-enable, set enabled = true and uncomment the keymap block.
      enabled = false,
    },
    panel = { enabled = true },
    filetypes = {
      markdown = true,
      help = true,
      -- Add or remove filetypes as needed
    },
    -- You can add more Copilot options here
  },
  config = function(_, opts)
    require("copilot").setup(opts)
  end,
}
