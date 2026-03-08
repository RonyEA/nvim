return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        r_language_server = {
          mason = false,
          cmd = { "R", "--slave", "-e", "languageserver::run()" },
        },

        -- Avoid duplicate diagnostics: use only basedpyright.
        pyright = false,
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
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
    },
  },
}
