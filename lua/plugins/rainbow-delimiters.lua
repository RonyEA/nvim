-- Bracket pairing by nesting depth, tone ramp only -- no new hue.
--
-- Ice Lavender assigns every hue a job (peach = params/members, blue = Type AND
-- docstrings, lavender = Keyword, pale blue = String). A depth rainbow has to
-- borrow one of those, so brackets stop reading as depth and start reading as
-- "that's a string, no wait". Lightness is the one channel still free, so depth
-- rides on three steps of the same neutral instead. Same reasoning as the
-- import-path change in theme.lua: hue means, lightness ranks.
--
-- COLOURS LIVE IN theme.lua, NOT HERE. aether re-applies its whole highlight
-- table on every colorscheme load and on the LazyReload hot-reload path, which
-- would wipe anything set from a plugin config. on_highlights is the only place
-- that survives a theme switch.
--
-- The `highlight` list length IS the cycle length: three entries means depth 4
-- restarts at depth 1. The group names are the plugin's own and read as
-- Red/Yellow/Blue regardless of what colour is in them -- they are slot numbers,
-- not colour names.
return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rd = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rd.strategy["global"],
        },
        highlight = {
          "RainbowDelimiterRed",    -- depth 1, outermost, brightest
          "RainbowDelimiterYellow", -- depth 2
          "RainbowDelimiterBlue",   -- depth 3, then cycles
        },
      }
    end,
  },
}
