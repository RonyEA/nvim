-- Language servers for the R and Python workflow.
--
-- Ported from RonyEA/nvim (lua/plugins/diagnostics.lua) on 2026-08-26.

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- LazyVim turns the builtin LSP inlay hints on by default. Off here:
      -- on typed Python they double the visual width of every line. Toggle
      -- per buffer with <leader>uh.
      inlay_hints = { enabled = false },

      servers = {
        -- Deliberately NOT installed through Mason. r_language_server is the R
        -- package `languageserver`, which has to run inside the same R that
        -- holds your libraries -- so it is launched from the system R directly.
        -- Install it once with:
        --   R -e 'install.packages("languageserver")'
        r_language_server = {
          mason = false,
          cmd = { "R", "--slave", "-e", "languageserver::run()" },
        },

        -- Avoid duplicate diagnostics: use only basedpyright. LazyVim's
        -- lang.python extra enables pyright by default, so this must stay.
        pyright = false,

        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                -- basedpyright is far stricter than pyright out of the box.
                -- These silence the inference noise that makes ordinary
                -- data-analysis code unreadable. Toggle the strict profile
                -- at runtime with <leader>uP (see lua/config/keymaps.lua).
                diagnosticSeverityOverrides = {
                  reportMissingTypeStubs = "none",
                  reportUnknownVariableType = "none",
                  reportUnknownMemberType = "none",
                  reportUnknownArgumentType = "none",
                  reportUnknownParameterType = "none",
                  reportUnknownLambdaType = "none",
                  reportOperatorIssue = "none",
                  reportAttributeAccessIssue = "none",
                },
              },
            },
          },
        },
      },

      -- Workaround: LazyVim's lang.python extra registers a `setup` handler for
      -- ruff that calls Snacks.util.lsp.on() to disable ruff's hover (leaving
      -- hover to basedpyright). It returns that call's value -- and in LazyVim,
      -- a truthy return from a setup handler means "handled, do not enable this
      -- server". Snacks returns a truthy value here, so ruff ends up configured
      -- with a valid `ruff server` cmd but never enabled, and silently never
      -- attaches. Verified: vim.lsp.enable("ruff") by hand attaches it fine.
      --
      -- Same behaviour, but explicitly returning false so LazyVim still enables it.
      setup = {
        ruff = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            client.server_capabilities.hoverProvider = false
          end)
          return false
        end,
      },
    },
  },
}
