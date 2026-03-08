return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    opts = function()
      local function get_python()
        if vim.env.VIRTUAL_ENV and #vim.env.VIRTUAL_ENV > 0 then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end

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

        return "python3"
      end

      return {
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            python = get_python,
            dap = { justMyCode = false },
          }),
        },
      }
    end,
    keys = {
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "Test nearest",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test file",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug nearest test",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Test output",
      },
    },
  },
}
