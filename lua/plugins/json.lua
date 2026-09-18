-- JSON: key navigation.
--
-- Only the plugin spec lives here; the rest of the JSON setup is not plugin
-- config and sits where it belongs:
--   * lazyvim.json                 enables lang.json (jsonls + SchemaStore)
--                                  and ui.treesitter-context
--   * lua/plugins/treesitter.lua   raises treesitter-context's line budget
--   * lua/config/json.lua          reflows minified one-line documents (jq)
--
-- jsonfly flattens the document into a list of key PATHS -- `a.b.c[0].d` --
-- and jumps to the one you pick, with the value previewed beside it. That is
-- what a deeply nested file actually needs, and neither of the two things
-- already in this config covers it: Outline (<leader>cs) walks one level at a
-- time and needs jsonls attached, and a grep finds the key but not which of
-- the nine parents named "name" it hangs off.

return {
  {
    "Myzel394/jsonfly.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },

    -- `ft` on a keys entry makes the mapping buffer-local, so <leader>cj is
    -- only claimed inside a JSON buffer and stays free everywhere else. The
    -- key is also what loads the plugin -- nothing of this is paid for until
    -- the first time it is pressed.
    keys = {
      {
        "<leader>cj",
        "<cmd>Telescope jsonfly<cr>",
        ft = { "json", "jsonc", "json5" },
        desc = "Jump to JSON Key",
      },
    },

    config = function()
      -- pcall to match lua/plugins/telescope.lua, which guards every
      -- load_extension the same way: a broken extension should cost you this
      -- one keymap, not take telescope down with it.
      pcall(require("telescope").load_extension, "jsonfly")
    end,
  },
}
