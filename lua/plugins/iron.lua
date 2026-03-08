return {
  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")

      iron.setup({
        config = {
          scratch_repl = true,

          repl_open_cmd = view.curry.center(function()
            return math.floor(vim.o.columns * 0.80) -- width
          end, function()
            return math.floor(vim.o.lines * 0.80) -- height
          end),

          repl_definition = {
            -- inside config = { repl_definition = { ... } }
            python = {
              command = function()
                -- 1) If you're already in an activated venv, use it.
                local venv = os.getenv("VIRTUAL_ENV")
                if venv and #venv > 0 then
                  return { venv .. "/bin/python", "-m", "IPython", "--no-autoindent" }
                end

                -- 2) Otherwise, search upwards from the current file for common venv folders.
                local buf = vim.api.nvim_buf_get_name(0)
                local start = buf ~= "" and vim.fs.dirname(buf) or vim.loop.cwd()

                local candidates = vim.fs.find({ ".venv", "venv", "env" }, {
                  path = start,
                  upward = true,
                  type = "directory",
                  stop = vim.loop.os_homedir(),
                })

                for _, dir in ipairs(candidates) do
                  local py = dir .. "/bin/python"
                  if vim.fn.executable(py) == 1 then
                    return { py, "-m", "IPython", "--no-autoindent" }
                  end
                end

                -- 3) Fallback (system python). Better than nothing.
                return { "python3", "-m", "IPython", "--no-autoindent" }
              end,

              format = require("iron.fts.common").bracketed_paste,
              block_dividers = { "# %%", "#%%" },
            },

            --            python = { command = { "ipython" } },
            r = { command = { "R" } },
          },
        },

        keymaps = {
          send_motion = "<leader>ic",
          visual_send = "<leader>ic",
          send_line = "<leader>il",
          send_file = "<leader>if",
          cr = "<leader>i<cr>",
          interrupt = "<leader>ii",
          exit = "<leader>iq",
          clear = "<leader>ix",
        },

        ignore_blank_lines = true,
      })

      vim.keymap.set("n", "<leader>rs", "<cmd>IronRepl<cr>", { desc = "REPL: start/toggle" })
      vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<cr>", { desc = "REPL: focus" })
      vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<cr>", { desc = "REPL: hide" })
    end,
  },
}
