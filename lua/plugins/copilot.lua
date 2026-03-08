return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter", -- Lazy load on first insert for faster startup
  opts = {
    suggestion = { enabled = true, auto_trigger = true },
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
