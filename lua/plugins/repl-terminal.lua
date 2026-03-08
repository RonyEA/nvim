return {
  {
    "akinsho/toggleterm.nvim",
    opts = function(_, opts)
      local ok, tt = pcall(require, "toggleterm.terminal")
      if not ok then
        return opts
      end

      local Terminal = tt.Terminal

      -- Dedicated REPL terminals
      _G.PY_REPL = Terminal:new({
        cmd = "ipython",
        direction = "float",
        hidden = true,
        float_opts = { border = "rounded" },
      })

      _G.R_REPL = Terminal:new({
        cmd = "radian",
        direction = "float",
        hidden = true,
        float_opts = { border = "rounded" },
      })

      return opts
    end,
    keys = {
      {
        "<leader>py",
        function()
          _G.PY_REPL:toggle()
        end,
        desc = "Python REPL (ipython)",
      },
      {
        "<leader>rr",
        function()
          _G.R_REPL:toggle()
        end,
        desc = "R REPL",
      },
    },
  },
}
