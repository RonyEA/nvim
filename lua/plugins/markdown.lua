-- Markdown / note-taking rendering.
--
-- LazyVim's lang.markdown extra provides marksman, markdownlint-cli2 and
-- render-markdown.nvim, but it strips render-markdown back to a minimal look:
-- no heading icons, no sign column, checkboxes off, code blocks sized to the
-- text. This file re-opens it for prose. Everything below is tuned for notes
-- and wiki-style linking rather than for reading a README.
--
-- Two constraints shaped the choices:
--   * lua/plugins/theme.lua is a symlink into ~/.local/state/omarchy, so the
--     colorscheme changes underneath us. Nothing here names a colour; it all
--     hangs off render-markdown's own highlight groups, which the theme fills.
--   * lua/config/autocmds.lua suppresses concealing for quarto/rmd, where the
--     ```{r} chunk headers are content rather than decoration.

-- Heading markers: a left rule that thins as the level deepens. Deliberately
-- geometric -- the plugin's default numbered circles read as clip-art next to
-- body prose, and pictographs date badly.
local heading_bars = { "▊ ", "▋ ", "▌ ", "▍ ", "▎ ", "▏ " }

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      -- The plugin's own installer. Needs node, which mise provides here.
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_theme = "dark"
      -- Do not steal focus from the editor when the preview opens.
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_open_to_the_world = 0
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview (browser)" },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        -- `position = "inline"` rather than the default "overlay": overlay
        -- left-pads the icon to cover the '#' run, which would stagger each
        -- level a further column on top of the `indent` module below. Inline
        -- conceals the markers outright, so the bar lands exactly on the
        -- indent guide and heading and body stay flush.
        position = "inline",
        icons = heading_bars,
        -- The bar already marks the line; a sign column glyph as well is
        -- clutter, and it widens the gutter permanently. Flip to true to get
        -- render-markdown's default 󰫎 marker back.
        sign = false,
        width = "full",
      },

      -- org-indent-mode. The single biggest change to how a long note reads:
      -- body text nests under the heading that owns it, so structure is
      -- visible while scrolling instead of having to be inferred from '#'
      -- counts. skip_level = 1 keeps H1 (the note title) flush left.
      indent = {
        enabled = true,
        per_level = 2,
        skip_level = 1,
        skip_heading = false,
        -- Thinner than any heading bar, so the guides stay subordinate.
        icon = "▏",
      },

      -- LazyVim disables checkboxes outright. For notes they are the point.
      -- The custom states follow Obsidian Tasks' vocabulary so a vault edited
      -- in both places renders the same.
      checkbox = {
        enabled = true,
        right_pad = 1,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰄬 ", highlight = "RenderMarkdownChecked", scope_highlight = "@markup.strikethrough" },
        custom = {
          -- [-] is the plugin's own default for "todo"; Obsidian reads it as
          -- cancelled, which is the more useful state to have in a note.
          cancelled = {
            raw = "[-]",
            rendered = "󰅖 ",
            highlight = "RenderMarkdownError",
            scope_highlight = "@markup.strikethrough",
          },
          in_progress = { raw = "[/]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          deferred = { raw = "[>]", rendered = "󰛁 ", highlight = "RenderMarkdownInfo" },
          important = { raw = "[!]", rendered = "󰀪 ", highlight = "RenderMarkdownWarn" },
          question = { raw = "[?]", rendered = "󰘥 ", highlight = "RenderMarkdownHint" },
          starred = { raw = "[*]", rendered = "󰓎 ", highlight = "RenderMarkdownSuccess" },
        },
      },

      -- Full-width blocks with the language named above them, so a code block
      -- in a note reads as an inset panel rather than as a ragged fragment.
      -- LazyVim sets width = "block" + right_pad = 1; both are undone here.
      code = {
        sign = true,
        width = "full",
        border = "thin",
        language_icon = true,
        language_name = true,
        left_pad = 2,
        right_pad = 2,
      },

      -- Off deliberately. This module shells out to latex2text/utftex and
      -- flattens a formula into Unicode text -- fine for `$x^2$`, but it has
      -- nowhere to put a fraction bar or a matrix. snacks.image below renders
      -- the same `$...$` as a real typeset image via tectonic, and if both are
      -- enabled they fight over the same nodes. Flip this to true (and install
      -- python-pylatexenc) if you ever want the lightweight path back, e.g.
      -- over a plain SSH session with no graphics protocol.
      latex = { enabled = false },

      bullet = { icons = { "●", "○", "◆", "◇" } },

      pipe_table = { preset = "round" },

      quote = {
        -- Carry the quote bar down wrapped lines. This needs 'showbreak',
        -- 'breakindent' and 'breakindentopt' set to specific values or it
        -- overwrites text -- win_options below sets them per-buffer while
        -- rendered, so the global settings stay untouched.
        repeat_linebreak = true,
      },

      win_options = {
        showbreak = { default = vim.o.showbreak, rendered = "  " },
        breakindent = { default = vim.o.breakindent, rendered = true },
        breakindentopt = { default = vim.o.breakindentopt, rendered = "" },
      },
    },
  },

  -- Inline images, via Ghostty's Kitty graphics protocol. Verified present on
  -- this machine: TERM_PROGRAM=ghostty and /usr/bin/magick (snacks shells out
  -- to ImageMagick for anything that is not already a PNG).
  --
  -- Pairs with <leader>op (ObsidianPasteImg) from lua/plugins/obsidian.lua:
  -- screenshot, paste, and the image is visible in the note rather than being
  -- a path you have to trust.
  {
    "folke/snacks.nvim",
    init = function()
      -- mermaid-cli drives a headless browser through puppeteer. It was
      -- installed with PUPPETEER_SKIP_DOWNLOAD=1, so puppeteer has no bundled
      -- Chromium and must be pointed at the system one. snacks.image has no
      -- env passthrough for its convert commands (`image.env` is terminal
      -- detection, not process env), so set it on nvim itself -- the `mmdc`
      -- child inherits it.
      if vim.fn.executable("chromium") == 1 then
        vim.env.PUPPETEER_EXECUTABLE_PATH = vim.fn.exepath("chromium")
      end
    end,
    opts = {
      image = {
        enabled = true,
        doc = {
          -- Render images inline where they are referenced, not only on
          -- demand. `float` keeps the hover preview available too.
          inline = true,
          float = true,
          max_width = 60,
          max_height = 30,
        },
        -- `$...$` and `$$...$$` compiled by tectonic to PDF, rasterised by
        -- ImageMagick, drawn through Ghostty's graphics protocol. The first
        -- render is slow: tectonic downloads the packages it needs into
        -- ~/.cache/Tectonic once, then it is fast.
        math = {
          enabled = true,
          latex = {
            -- snacks' template emits `\color[HTML]{...}` to tint the formula to
            -- the editor foreground, but its default package list omits
            -- xcolor, and the standalone class does not pull xcolor in on its
            -- own. Without it the \color line fails, and because the tectonic
            -- step runs with -Z continue-on-errors the build still succeeds --
            -- it just renders the literal text "[HTML]F0F8FF" as a stray line
            -- above every formula, in grayscale. Verified against the real
            -- template: adding xcolor drops the image from 194px to 114px and
            -- from Grayscale to sRGB.
            packages = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools", "xcolor" },
          },
        },
      },
    },
  },
}
