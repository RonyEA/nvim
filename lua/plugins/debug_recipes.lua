return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dQ",
        function()
          require("debug.bp_trading").apply()
          vim.notify("Debug breakpoints applied (recipe)", vim.log.levels.INFO)
        end,
        desc = "DAP Apply breakpoint recipe",
      },
    },
  },
}
