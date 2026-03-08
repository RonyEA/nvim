return {
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    keys = {
      {
        "<leader>dpm",
        function()
          require("dap-python").test_method()
        end,
        desc = "DAP Python: debug method",
      },
      {
        "<leader>dpc",
        function()
          require("dap-python").test_class()
        end,
        desc = "DAP Python: debug class",
      },
      {
        "<leader>dps",
        function()
          require("dap-python").debug_selection()
        end,
        mode = "v",
        desc = "DAP Python: debug selection",
      },
    },
    config = function()
      local dap_python = require("dap-python")

      local function get_python()
        -- 1) Current activated environment.
        if vim.env.VIRTUAL_ENV and #vim.env.VIRTUAL_ENV > 0 then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end

        -- 2) Search project-local virtualenv folders.
        local file = vim.api.nvim_buf_get_name(0)
        local start = file ~= "" and vim.fs.dirname(file) or vim.loop.cwd()
        local candidates = vim.fs.find({ ".venv", "venv", "env" }, {
          path = start,
          upward = true,
          type = "directory",
          stop = vim.loop.os_homedir(),
        })

        for _, dir in ipairs(candidates) do
          local py = dir .. "/bin/python"
          if vim.fn.executable(py) == 1 then
            return py
          end
        end

        -- 3) Best effort fallback.
        return "python3"
      end

      dap_python.setup(get_python())
    end,
  },
}
