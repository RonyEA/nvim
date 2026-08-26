-- R debugging via the vscDebugger R package.
--   R -e 'install.packages("vscDebugger")'
--
-- IMPORTANT: this deliberately does NOT use `config = function() ... end` on
-- nvim-dap, which is how the original RonyEA/nvim version was written. In
-- lazy.nvim a later `config` REPLACES an earlier one, so that spec silently
-- wiped LazyVim's own nvim-dap config -- launch.json loading via
-- mason-nvim-dap and the DapStoppedLine highlight. Registering the adapter
-- after nvim-dap loads leaves LazyVim's config intact.

local function register_r_adapter()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return
  end

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
end

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      -- nvim-dap may already be loaded (another spec's `keys` can pull it in
      -- first), in which case the LazyLoad event has been and gone.
      if package.loaded["dap"] then
        register_r_adapter()
        return
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(ev)
          if ev.data == "nvim-dap" then
            register_r_adapter()
            return true -- one-shot: delete the autocmd
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>dR",
        function()
          if vim.fn.executable("R") ~= 1 then
            vim.notify("R executable not found in PATH", vim.log.levels.ERROR)
            return
          end
          require("dap").continue()
        end,
        desc = "DAP R: debug current file",
      },
    },
  },
}
