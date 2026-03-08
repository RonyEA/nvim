return {
  {
    "mfussenegger/nvim-dap",
    ft = { "r", "rmd", "quarto" },
    config = function()
      local dap = require("dap")

      -- R DAP via vscDebugger package: install in R with
      -- install.packages("vscDebugger")
      dap.adapters.r = {
        type = "executable",
        command = "R",
        args = { "--silent", "-e", "vscDebugger::.vsc.listen()" },
      }

      dap.configurations.r = {
        {
          type = "r",
          request = "launch",
          name = "R: Debug current file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      }

      vim.keymap.set("n", "<leader>dR", function()
        if vim.fn.executable("R") ~= 1 then
          vim.notify("R executable not found in PATH", vim.log.levels.ERROR)
          return
        end
        require("dap").continue()
      end, { desc = "DAP R: debug current file" })
    end,
  },
}
