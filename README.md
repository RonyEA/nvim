# nvim

Neovim config for an R + Python + Quarto workflow, running on **Omarchy**
(Arch + Hyprland). LazyVim base.

This replaced the pre-Omarchy version of this repo on 2026-08-26. The old
config is still in this repo's history, before commit "Rebuild on Omarchy's
LazyVim".

## What this is

Omarchy ships its own preconfigured LazyVim. Rather than replace it, this
config **merges into it** — Omarchy's theme integration, transparency and
OSC-52 clipboard are left untouched, and the R/Python/coding layer sits on top.
That matters practically: `omarchy theme set <name>` still restyles Neovim,
because `lua/plugins/theme.lua` is a **symlink** into
`~/.local/state/omarchy/current/theme/`.

Files owned by Omarchy — do not edit, they came from the `omarchy-nvim` package:

```
lua/plugins/theme.lua                    -> symlink, theme sync
lua/plugins/all-themes.lua                  21 pre-cached colorschemes
lua/plugins/omarchy-theme-hotreload.lua     live theme reload
lua/plugins/disable-news-alert.lua
lua/plugins/snacks-animated-scrolling-off.lua
lua/config/remote_clipboard.lua             OSC-52 yank over tmux/SSH
plugin/after/transparency.lua               transparent background
```

## Requirements

| Tool | Why | Install |
|---|---|---|
| `R` + `languageserver` | R LSP | `pacman -S r`; `R -e 'install.packages("languageserver")'` |
| `vscDebugger` | R debugging (`<leader>dR`) | `R -e 'install.packages("vscDebugger", repos="https://manuelhentschel.r-universe.dev")'` |
| `radian` | R REPL used with slime | `pip install radian` |
| `tmux` | **required** by vim-slime | `pacman -S tmux` |
| `quarto`, `pandoc` | `.qmd` preview/render | `yay -S quarto-cli`; `pacman -S pandoc-cli` |
| `ruff` | Python lint/format | `pacman -S ruff` |

Mason installs the rest on first launch: `basedpyright`, `marksman`,
`markdownlint-cli2`, `debugpy`.

## The REPL workflow

**vim-slime is the only REPL path.** Earlier versions of this config carried
five overlapping ones (iron.nvim, molten, toggleterm floats, R.nvim's console,
slime); they collided on the `<leader>r*` prefix and none shared state.

Neovim must be running **inside tmux**:

1. Start tmux, open a second pane, run `radian` (R) or `ipython` (Python).
2. In Neovim, `<leader>sc` **once** to pick that pane.
3. `<leader>sl` line · `<leader>sp` paragraph · `<leader>s;` selection (visual).

In `.qmd` files, quarto-nvim's code runner is wired to slime, so its own
chunk-running commands go to the same pane.

## Keymaps

Leader is `<Space>`.

### REPL
| Key | Mode | Action |
|---|---|---|
| `<leader>sc` | n | Slime: pick tmux pane (run once per session) |
| `<leader>sl` | n | Send line |
| `<leader>sp` | n | Send paragraph |
| `<leader>s;` | v | Send selection |

### LSP navigation
| Key | Action |
|---|---|
| `<leader>sd` | Definitions |
| `<leader>si` | Implementations (grep fallback) |
| `<leader>sr` | References (grep fallback) |
| `<leader>ss` / `<leader>sS` | Document / workspace symbols |
| `<leader>so` / `<leader>sI` | Outgoing / incoming calls |
| `<leader>uP` | Toggle Python strict diagnostics |

### Quarto
| Key | Mode | Action |
|---|---|---|
| `<leader>qp` / `<leader>qr` / `<leader>qa` | n | Preview / render / activate |
| `<leader>qir` `<leader>qip` `<leader>qib` | n | Insert R / Python / Bash chunk |
| `<leader>qwr` `<leader>qwp` `<leader>qwb` | v | Wrap selection in a chunk |

### Python / testing / debug
| Key | Action |
|---|---|
| `<leader>vs` | Select venv |
| `<leader>tn` / `<leader>tf` / `<leader>ts` | Test nearest / file / summary |
| `<leader>dR` | Debug current R file |
| `<leader>dpm` / `<leader>dpc` | Debug Python test method / class |

### Files (Telescope)
`<leader>ff` smart find · `<leader>fg` grep · `<leader>fb` buffers ·
`<leader>fR` frecency · `<leader>fP` project files · `<leader>gP` project grep ·
`<leader>gs` git status

### Markdown / notes
`<leader>mp` browser preview · `<leader>o*` Obsidian (11 maps, see
`lua/plugins/obsidian.lua`)

### AI
`<leader>ac` Claude Code · `<leader>aa` Copilot Chat · `<leader>aw` workspace
audit · `<leader>aD` deep audit · `<leader>aB` ask about open buffers

## Known collisions

Deliberate, inherited from the pre-Omarchy config:

- `<leader>sd` / `<leader>sr` / `<leader>ss` shadow LazyVim's search maps.
- `<leader>cf` (visual, CopilotChat fix) shadows LazyVim's **format**. Omarchy
  sets `vim.g.autoformat = false`, so manual format matters here — rename this
  in `lua/plugins/ai.lua` if you want it back.
- The `<leader>s*` prefix is shared between slime and LSP navigation.

## Two upstream workarounds

Both fail *silently*, so they are worth knowing about before "fixing" them:

1. **`vim.g.lazyvim_python_lsp = "basedpyright"`** in `lua/config/options.lua`.
   LazyVim's `lang.python` extra defaults to pyright; setting `pyright = false`
   without this leaves Python with **no** language server at all. It must be in
   `options.lua` — a plugin spec runs too late.

2. **The `setup.ruff` override** in `lua/plugins/lsp.lua`. LazyVim's ruff setup
   handler returns whatever `Snacks.util.lsp.on()` returns, and a truthy return
   means "handled, do not enable". Ruff ends up configured with a valid
   `ruff server` cmd but never attaches. The override does the same
   hover-disabling and explicitly returns `false`.
